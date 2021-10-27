import socket
import time
import SSD1306
from PIL import Image, ImageDraw, ImageFont
import threading


def wait_for_internet_connection():
    iteration = 0
    while True:
        try:
            iteration += 1
            print(iteration)
            if iteration == 10000:
                break
                socket.create_connection(("www.google.com", 80))
                return
        except Exception as e:
            pass


def get_ip():
    # wait_for_internet_connection()
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception as e:
        IP = e
    finally:
        s.close()

    return IP


def display_on_board(text):
    show = SSD1306.SSD1306()
    try:
        # Initialize library.
        show.Init()
        show.ClearBlack()
        # Create blank image for drawing.
        image1 = Image.new('1', (show.width, show.height), "WHITE")
        draw = ImageDraw.Draw(image1)
        draw.rectangle((0, 0, 127, 31), outline=0)
        draw.text((5, 2), text,
                  font=ImageFont.truetype('/home/jointload/Desktop/EPIC-Lab-Scripts/Display IP/Font.ttf', 17))
        show.ShowImage(show.getbuffer(image1))
        time.sleep(2)
        show.ShowImage(show.getbuffer(image1))
        show.Closebus()
    except IOError as e:
        show.Closebus()
        print(e)
    except KeyboardInterrupt:
        print("ctrl + c:")
        show.Closebus()


def main():
    IP = get_ip()
    display_on_board(IP)


if __name__ == '__main__':
    ip_thread = threading.Thread(target=main, name="main")
    ip_thread.start()
