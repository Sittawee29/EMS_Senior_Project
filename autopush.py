import os
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class GitAutoPush(FileSystemEventHandler):
    def on_modified(self, event):
        if event.is_directory:
            return
        print(f"🔄 File changed: {event.src_path}")
        os.system("git add .")
        os.system('git commit -m \"auto update\"')
        os.system("git push origin main")
        print("✅ Code pushed to GitHub")

if __name__ == "__main__":
    path = "."
    event_handler = GitAutoPush()
    observer = Observer()
    observer.schedule(event_handler, path, recursive=True)
    observer.start()
    print("👀 Watching for file changes... (Ctrl+C to stop)")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
