
#!/home/mastermind/bash/notes/venv/bin/python3
import i3ipc
import asyncio
from threading import Thread

tracked_windows = {}
polling_interval = 0.5  # 500 milliseconds

# Synchronous callback for i3ipc
def on_window_floating(i3, event):
    container = event.container
    if "NOTE_" in container.name:
        tracked_windows[container.id] = {
            "name": container.name,
            "x": container.rect.x,
            "y": container.rect.y,
            "width": container.rect.width,
            "height": container.rect.height
        }

# Run i3.main() in a separate thread
def i3_thread():
    i3 = i3ipc.Connection()
    i3.on("window::floating", on_window_floating)
    i3.main()

# Asynchronous custom polling loop
async def poll_tracked_windows():
    i3 = i3ipc.Connection()
    while True:
        await asyncio.sleep(polling_interval)

        for window_id in list(tracked_windows.keys()):
            window = i3.get_tree().find_by_id(window_id)
            if window:
                new_x, new_y, new_width, new_height = window.rect.x, window.rect.y, window.rect.width, window.rect.height
                if (
                        new_x, new_y, new_width, new_height
                    ) != (
                        tracked_windows[window_id]["x"],
                        tracked_windows[window_id]["y"],
                        tracked_windows[window_id]["width"],
                        tracked_windows[window_id]["height"]
                    ):
                    print(f"Note window {window.name} moved or resized, saving positions and dimensions.")
                    tracked_windows[window_id].update({
                        "x": new_x,
                        "y": new_y,
                        "width": new_width,
                        "height": new_height
                    })

                    await asyncio.create_subprocess_shell(
                        "/home/mastermind/bash/notes/save_positions.sh"
                    )

if __name__ == "__main__":
    # Start i3 event handling in a separate thread
    Thread(target=i3_thread).start()

    # Start asyncio event loop
    asyncio.run(poll_tracked_windows())
