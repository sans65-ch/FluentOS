#!/usr/bin/env python3
"""
Windows Drive Manager for FluentOS
自动检测和挂载 Windows 分区，提供 Windows 程序访问接口
"""

import os
import subprocess
import json
import re
from pathlib import Path
from typing import List, Optional, Dict

class WindowsDriveManager:
    """Windows 分区管理器"""

    def __init__(self):
        self.mount_base = "/mnt/windows"
        self.config_dir = Path.home() / ".config" / "fluentos"
        self.config_file = self.config_dir / "windows-drives.json"
        self.programs_cache = self.config_dir / "programs-cache.json"
        self._ensure_dirs()

    def _ensure_dirs(self):
        """确保必要目录存在"""
        self.config_dir.mkdir(parents=True, exist_ok=True)
        Path(self.mount_base).mkdir(parents=True, exist_ok=True)

    def get_windows_drives(self) -> List[Dict]:
        """获取所有 Windows 分区"""
        drives = []

        # 使用 lsblk 获取块设备
        try:
            result = subprocess.run(
                ['lsblk', '-J', '-o', 'NAME,SIZE,TYPE,MOUNTPOINT,LABEL,FSTYPE'],
                capture_output=True, text=True, check=True
            )
            data = json.loads(result.stdout)

            for device in data.get('blockdevices', []):
                if device.get('type') == 'part' and device.get('fstype') == 'ntfs':
                    drive_info = {
                        'device': f"/dev/{device['name']}",
                        'size': device.get('size', ''),
                        'label': device.get('label', '本地磁盘'),
                        'mountpoint': device.get('mountpoint', ''),
                        'fstype': 'ntfs',
                        'uuid': self._get_uuid(device['name'])
                    }
                    drives.append(drive_info)

        except (subprocess.CalledProcessError, json.JSONDecodeError) as e:
            print(f"Error getting drives: {e}")

        return drives

    def _get_uuid(self, device_name: str) -> str:
        """获取设备的 UUID"""
        try:
            result = subprocess.run(
                ['blkid', '-s', 'UUID', '-o', 'value', f'/dev/{device_name}'],
                capture_output=True, text=True, check=True
            )
            return result.stdout.strip()
        except subprocess.CalledProcessError:
            return ""

    def mount_drive(self, device: str, label: str = "") -> Optional[str]:
        """挂载 Windows 分区"""
        mount_point = f"{self.mount_base}/{label.replace(' ', '_')}" if label else f"{self.mount_base}/{os.path.basename(device)}"

        # 检查是否已经挂载
        try:
            result = subprocess.run(
                ['findmnt', '-n', '-o', 'TARGET', device],
                capture_output=True, text=True
            )
            if result.stdout.strip():
                return result.stdout.strip()
        except subprocess.CalledProcessError:
            pass

        # 创建挂载点并挂载
        Path(mount_point).mkdir(parents=True, exist_ok=True)

        try:
            # 挂载为可读写
            subprocess.run(
                ['sudo', 'mount', '-o', 'rw,uid=1000,gid=1000,umask=022', device, mount_point],
                check=True
            )
            self._save_mount_config(device, mount_point)
            return mount_point
        except subprocess.CalledProcessError as e:
            print(f"Mount error: {e}")
            # 尝试只读挂载
            try:
                subprocess.run(
                    ['sudo', 'mount', '-o', 'ro', device, mount_point],
                    check=True
                )
                return mount_point
            except subprocess.CalledProcessError:
                return None

    def unmount_drive(self, mount_point: str) -> bool:
        """卸载分区"""
        try:
            subprocess.run(['sudo', 'umount', mount_point], check=True)
            self._remove_mount_config(mount_point)
            return True
        except subprocess.CalledProcessError:
            return False

    def _save_mount_config(self, device: str, mount_point: str):
        """保存挂载配置"""
        config = self._load_config()
        config[device] = mount_point
        with open(self.config_file, 'w') as f:
            json.dump(config, f)

    def _remove_mount_config(self, mount_point: str):
        """移除挂载配置"""
        config = self._load_config()
        config = {k, v for k, v in config.items() if v != mount_point}
        with open(self.config_file, 'w') as f:
            json.dump(config, f)

    def _load_config(self) -> Dict:
        """加载配置"""
        if self.config_file.exists():
            with open(self.config_file, 'r') as f:
                return json.load(f)
        return {}

    def find_windows_programs(self, mount_point: str) -> List[Dict]:
        """在 Windows 分区中查找可执行程序"""
        programs = []
        search_paths = [
            f"{mount_point}/Program Files",
            f"{mount_point}/Program Files (x86)",
            f"{mount_point}/ProgramData/Microsoft/Windows/Start Menu/Programs"
        ]

        # 常见程序子目录
        common_dirs = [
            "Microsoft Office",
            "Google",
            "Adobe",
            "Mozilla",
            "Tencent",
            "Baidu",
            "AliWangWang",
            "WeChat",
            "QQ",
            "Steam",
            "Epic Games",
            "NVIDIA",
            "Intel",
            "AMD",
            "Realtek",
            "DLL-files"
        ]

        for base_path in search_paths:
            if not os.path.exists(base_path):
                continue

            # 扫描常见程序目录
            for common_dir in common_dirs:
                full_path = os.path.join(base_path, common_dir)
                if os.path.exists(full_path):
                    self._scan_directory(full_path, programs)

            # 扫描根目录的 exe 文件
            self._scan_directory(base_path, programs)

        # 扫描开始菜单快捷方式
        start_menu_path = f"{mount_point}/ProgramData/Microsoft/Windows/Start Menu/Programs"
        if os.path.exists(start_menu_path):
            self._scan_shortcuts(start_menu_path, programs)

        return programs

    def _scan_directory(self, directory: str, programs: List[Dict], depth: int = 0):
        """递归扫描目录查找 exe 文件"""
        if depth > 3:  # 限制深度
            return

        try:
            for entry in os.scandir(directory):
                if entry.is_file() and entry.name.endswith('.exe'):
                    # 排除安装程序和卸载程序
                    if any(x in entry.name.lower() for x in ['uninstall', 'setup', 'install', 'update', 'helper', 'launcher']):
                        continue

                    program_info = {
                        'name': entry.name.replace('.exe', ''),
                        'path': entry.path,
                        'size': entry.stat().st_size,
                        'type': 'executable'
                    }
                    programs.append(program_info)

                elif entry.is_dir() and depth < 3:
                    self._scan_directory(entry.path, programs, depth + 1)

        except PermissionError:
            pass

    def _scan_shortcuts(self, directory: str, programs: List[Dict]):
        """扫描开始菜单快捷方式"""
        try:
            for entry in os.scandir(directory):
                if entry.is_file() and entry.name.endswith('.lnk'):
                    # 尝试读取快捷方式指向
                    name = entry.name.replace('.lnk', '')
                    program_info = {
                        'name': name,
                        'path': entry.path,
                        'type': 'shortcut'
                    }
                    programs.append(program_info)

                elif entry.is_dir():
                    self._scan_shortcuts(entry.path, programs)

        except PermissionError:
            pass

    def cache_programs(self, mount_point: str):
        """缓存程序列表"""
        programs = self.find_windows_programs(mount_point)
        with open(self.programs_cache, 'w') as f:
            json.dump(programs, f, indent=2)
        return programs

    def get_cached_programs(self) -> List[Dict]:
        """获取缓存的程序列表"""
        if self.programs_cache.exists():
            with open(self.programs_cache, 'r') as f:
                return json.load(f)
        return []

    def launch_windows_program(self, program_path: str) -> bool:
        """启动 Windows 程序"""
        # 检查是否是 Linux 上的 Windows 程序（如通过 Wine）
        if program_path.endswith('.exe'):
            try:
                # 尝试使用 wine 运行
                subprocess.Popen(['wine', program_path])
                return True
            except FileNotFoundError:
                # wine 未安装，提示用户
                print("Wine is not installed. Cannot run Windows executables.")
                return False
        return False


def main():
    """命令行接口"""
    manager = WindowsDriveManager()

    import argparse
    parser = argparse.ArgumentParser(description='Windows Drive Manager for FluentOS')
    parser.add_argument('--list-drives', action='store_true', help='列出 Windows 分区')
    parser.add_argument('--mount', metavar='DEVICE', help='挂载指定分区')
    parser.add_argument('--unmount', metavar='MOUNTPOINT', help='卸载指定分区')
    parser.add_argument('--find-programs', action='store_true', help='查找 Windows 程序')
    parser.add_argument('--mount-all', action='store_true', help='挂载所有 Windows 分区')

    args = parser.parse_args()

    if args.list_drives:
        drives = manager.get_windows_drives()
        print(json.dumps(drives, indent=2, ensure_ascii=False))

    elif args.mount:
        result = manager.mount_drive(args.mount)
        if result:
            print(f"Mounted at: {result}")
        else:
            print("Mount failed")

    elif args.unmount:
        if manager.unmount_drive(args.unmount):
            print("Unmounted successfully")
        else:
            print("Unmount failed")

    elif args.mount_all:
        drives = manager.get_windows_drives()
        for drive in drives:
            if not drive.get('mountpoint'):
                result = manager.mount_drive(drive['device'], drive.get('label', ''))
                if result:
                    print(f"Mounted {drive['device']} at {result}")

    elif args.find_programs:
        drives = manager.get_windows_drives()
        all_programs = []
        for drive in drives:
            mount_point = drive.get('mountpoint') or manager.mount_drive(drive['device'], drive.get('label', ''))
            if mount_point:
                programs = manager.find_windows_programs(mount_point)
                all_programs.extend(programs)
        print(json.dumps(all_programs, indent=2, ensure_ascii=False))


if __name__ == '__main__':
    main()
