#!/bin/bash

# Install dependensi yang diperlukan
sudo apt update
sudo apt install -y python3-pip sqlite3

# Buat file bot Telegram
cat <<EOF > bot.py
import telebot
from telebot import types
import sqlite3

# Ganti 'TOKEN_BOT_ANDA' dengan token bot Telegram Anda
bot = telebot.TeleBot('6474341901:AAH574AEKvhq1jK_N0NMBLjGezFbXDQLm-s')

# ID admin bot (ganti dengan ID Anda)
ADMIN_ID = "576495165"

# Koneksi ke database SQLite
conn = sqlite3.connect('saldo.db')
cursor = conn.cursor()

# Membuat tabel saldo jika belum ada
cursor.execute('''CREATE TABLE IF NOT EXISTS saldo (
                chat_id INTEGER PRIMARY KEY,
                saldo INTEGER DEFAULT 0
                )''')
conn.commit()

# Dictionary untuk menyimpan harga setiap jumlah IP untuk setiap protokol
harga = {
    "ssh_1_ip": 3000,
    "ssh_2_ip": 5000,
    "ssh_5_ip": 10000,
    "vmess_1_ip": 3000,
    "vmess_2_ip": 5000,
    "vmess_5_ip": 10000,
    "vless_1_ip": 3000,
    "vless_2_ip": 5000,
    "vless_5_ip": 10000,
    "trojan_1_ip": 3000,
    "trojan_2_ip": 5000,
    "trojan_5_ip": 10000
}

@bot.message_handler(commands=['start'])
def start(message):
    chat_id = message.chat.id
    markup = types.InlineKeyboardMarkup()
    ssh_button = types.InlineKeyboardButton(text="SSH", callback_data="ssh")
    vmess_button = types.InlineKeyboardButton(text="VMESS", callback_data="vmess")
    vless_button = types.InlineKeyboardButton(text="VLESS", callback_data="vless")
    trojan_button = types.InlineKeyboardButton(text="TROJAN", callback_data="trojan")
    markup.add(ssh_button, vmess_button, vless_button, trojan_button)
    # Mendapatkan saldo dari database
    cursor.execute("SELECT saldo FROM saldo WHERE chat_id=?", (chat_id,))
    result = cursor.fetchone()
    saldo = result[0] if result else 0
    bot.send_message(chat_id, f"Selamat datang! Saldo Anda saat ini adalah: {saldo}", reply_markup=markup)
    # Menambahkan tombol untuk menambah saldo hanya jika pengguna adalah admin
    if str(chat_id) == ADMIN_ID:
        add_balance_button = types.InlineKeyboardButton(text="Tambah Saldo", callback_data="add_balance")
        markup.add(add_balance_button)
        bot.send_message(chat_id, "Anda adalah admin. Anda dapat menambahkan saldo.", reply_markup=markup)

@bot.callback_query_handler(func=lambda call: True)
def callback_query(call):
    if call.data == "ssh":
        markup = types.InlineKeyboardMarkup()
        ip1_button = types.InlineKeyboardButton(text="1 IP - 3000", callback_data="ssh_1_ip")
        ip2_button = types.InlineKeyboardButton(text="2 IP - 5000", callback_data="ssh_2_ip")
        ip5_button = types.InlineKeyboardButton(text="5 IP - 10000", callback_data="ssh_5_ip")
        markup.add(ip1_button, ip2_button, ip5_button)
        bot.send_message(call.message.chat.id, "Pilih jumlah IP untuk SSH:", reply_markup=markup)
    elif call.data == "vmess":
        markup = types.InlineKeyboardMarkup()
        ip1_button = types.InlineKeyboardButton(text="1 IP - 3000", callback_data="vmess_1_ip")
        ip2_button = types.InlineKeyboardButton(text="2 IP - 5000", callback_data="vmess_2_ip")
        ip5_button = types.InlineKeyboardButton(text="5 IP - 10000", callback_data="vmess_5_ip")
        markup.add(ip1_button, ip2_button, ip5_button)
        bot.send_message(call.message.chat.id, "Pilih jumlah IP untuk VMESS:", reply_markup=markup)
    elif call.data == "vless":
        markup = types.InlineKeyboardMarkup()
        ip1_button = types.InlineKeyboardButton(text="1 IP - 3000", callback_data="vless_1_ip")
        ip2_button = types.InlineKeyboardButton(text="2 IP - 5000", callback_data="vless_2_ip")
        ip5_button = types.InlineKeyboardButton(text="5 IP - 10000", callback_data="vless_5_ip")
        markup.add(ip1_button, ip2_button, ip5_button)
        bot.send_message(call.message.chat.id, "Pilih jumlah IP untuk VLESS:", reply_markup=markup)
    elif call.data == "trojan":
        markup = types.InlineKeyboardMarkup()
        ip1_button = types.InlineKeyboardButton(text="1 IP - 3000", callback_data="trojan_1_ip")
        ip2_button = types.InlineKeyboardButton(text="2 IP - 5000", callback_data="trojan_2_ip")
        ip5_button = types.InlineKeyboardButton(text="5 IP - 10000", callback_data="trojan_5_ip")
        markup.add(ip1_button, ip2_button, ip5_button)
        bot.send_message(call.message.chat.id, "Pilih jumlah IP untuk TROJAN:", reply_markup=markup)
    elif call.data == "add_balance":
        bot.send_message(call.message.chat.id, "Masukkan ID chat yang ingin Anda tambahkan saldo:")
        bot.register_next_step_handler(call.message, process_add_balance)

def process_add_balance(message):
    try:
        chat_id = int(message.text)
        bot.send_message(chat_id, "Masukkan jumlah saldo yang ingin Anda tambahkan:")
        bot.register_next_step_handler(message, process_amount, chat_id)
    except Exception as e:
        bot.send_message(call.message.chat.id, "ID chat tidak valid.")

def process_amount(message, chat_id):
    try:
        amount = int(message.text)
        cursor.execute("SELECT saldo FROM saldo WHERE chat_id=?", (chat_id,))
        result = cursor.fetchone()
        current_balance = result[0] if result else 0
        new_balance = current_balance + amount
        cursor.execute("INSERT OR REPLACE INTO saldo (chat_id, saldo) VALUES (?, ?)", (chat_id, new_balance))
        conn.commit()
        bot.send_message(chat_id, f"Saldo Anda telah ditambahkan sebesar {amount}. Saldo Anda sekarang adalah {new_balance}.")
    except Exception as e:
        bot.send_message(chat_id, "Terjadi kesalahan. Mohon coba lagi.")

bot.polling()
EOF

# Beri izin eksekusi pada file bot.py
chmod +x bot.py

# Mulai bot di background menggunakan nohup
nohup ./bot.py &
