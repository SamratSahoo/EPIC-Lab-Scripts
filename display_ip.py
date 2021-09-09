import socket
import sys
import time

import board
import busio
from adafruit_character_lcd import character_lcd


def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP


def display_on_board(text, rows=2, cols=16, run_time=sys.maxsize):
    # For I2C Ports
    i2c = busio.I2C(board.SCL, board.SDA)
    lcd = character_lcd.Character_LCD_I2C(i2c, cols, rows)
    lcd.message = text
    lcd.backlight = True
    # Run until termination of python program
    time.sleep(run_time)


if __name__ == '__main__':
    display_on_board(get_ip())
