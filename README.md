# 🚀 Telemt MTProto Proxy Installer

<p align="center">
  <b>Beautiful one-file MTProto FakeTLS installer for Ubuntu/Debian</b><br>
  <sub>installer by <b>n0tkaXD</b></sub>
</p>

<p align="center">
  <img alt="Shell" src="https://img.shields.io/badge/shell-bash-121011?style=for-the-badge&logo=gnu-bash&logoColor=white">
  <img alt="MTProto" src="https://img.shields.io/badge/MTProto-FakeTLS-229ED9?style=for-the-badge&logo=telegram&logoColor=white">
  <img alt="Systemd" src="https://img.shields.io/badge/systemd-service-00AEEF?style=for-the-badge">
  <img alt="Dockerless" src="https://img.shields.io/badge/docker-not_required-2496ED?style=for-the-badge&logo=docker&logoColor=white">
</p>

<p align="center">
  <a href="#-русский">Русский</a> ·
  <a href="#-english">English</a> ·
  <a href="#-日本語">日本語</a>
</p>

<p align="center">
  <a href="https://github.com/n0tkaXD/mtproto-installer/blob/main/telemt-installer.sh"><b>📦 telemt-installer.sh on GitHub</b></a>
</p>

---

## 🌍 Русский

### Что это?

**Telemt MTProto Proxy Installer** — это красивый однокомандный установщик MTProto-прокси на базе **Telemt**.

Он ставит прокси в режиме **FakeTLS**, создаёт systemd-сервис, генерирует рабочую Telegram-ссылку, умеет показывать активные подключения, менять рекламный `ad tag` и аккуратно удаляться без грязи в системе.

Сделано как нормальный GitHub-ready installer: один `.sh` файл, интерактивное меню, понятные команды, минимум лишнего шума.

---

### ✨ Возможности

- ✅ Установка **Telemt MTProto Proxy** без Docker.
- ✅ Режим **FakeTLS** (`ee...` secret), который обычно живёт лучше старого `dd`.
- ✅ Красивое интерактивное меню.
- ✅ Генерация Telegram-ссылки.
- ✅ Live monitor:
  - активные TCP-соединения;
  - активные IP;
  - примерная оценка устройств;
  - трафик по пользователю;
  - ad tag status.
- ✅ Выбор **ad tag** от `@MTProxybot`.
- ✅ Команды `install`, `monitor`, `link`, `status`, `restart`, `adtag`, `uninstall`.
- ✅ Systemd-сервис `telemt`.
- ✅ UFW открывается автоматически, если он активен.
- ✅ Не трогает Docker, Remnawave, nginx, Xray, node и прочие контейнеры.
- ✅ По умолчанию не трогает порт `443`.

---

### ⚠️ Важные нюансы

**Это не Docker-инсталлер.**  
Скрипт ставит Telemt бинарником и запускает его через systemd.

**Порт 443 защищён.**  
Инсталлер откажется использовать `443`, если явно не указать `--force-443`. Это сделано специально, чтобы не убить существующий nginx / reverse proxy / Remnawave / Xray / другую ноду.

**Устройства считаются примерно.**  
MTProto-прокси не видит “телефон”, “ноутбук” или “планшет” как отдельную сущность. Он видит TCP-соединения и IP-адреса. Один Telegram-клиент может открывать несколько соединений, поэтому монитор показывает оценку устройств, а не железобетонную правду.

**Ad tag необязателен.**  
Если у тебя нет тега от `@MTProxybot`, просто оставь поле пустым. Прокси будет работать без него.

---

### 📦 Требования

Подойдёт обычный VPS на Ubuntu/Debian.

Минимум:

- Ubuntu 20.04 / 22.04 / 24.04 или Debian 11/12;
- root-доступ;
- `systemd`;
- открытый TCP-порт, например `8443`;
- архитектура `x86_64` или `aarch64`.

Скрипт сам проверит зависимости. Если нет `curl` или `python3`, он попробует поставить их через `apt`.

---

### 🚀 Быстрый старт

Скачай файл:

```bash
curl -fsSL https://raw.githubusercontent.com/n0tkaXD/mtproto-installer/main/telemt-installer.sh -o telemt-installer.sh
chmod +x telemt-installer.sh
sudo ./telemt-installer.sh
```

Или запусти напрямую:

```bash
sudo bash telemt-installer.sh
```

Дальше появится интерактивное меню.

---

Ссылка на файл в репозитории:

```text
https://github.com/n0tkaXD/mtproto-installer/blob/main/telemt-installer.sh
```

Для `curl` используется raw-ссылка, потому что GitHub `blob`-страница отдаёт HTML, а не сам `.sh` файл.

### 🧭 Интерактивная установка

```bash
sudo bash telemt-installer.sh
```

При первом запуске скрипт спросит:

```text
Proxy port [8443]:
FakeTLS domain [www.cloudflare.com]:
User name [main]:
Ad tag from @MTProxybot [empty = disabled]:
```

Рекомендуемые значения:

```text
Port: 8443
FakeTLS domain: www.cloudflare.com
User name: main
Ad tag: пусто, если нет тега
```

После установки скрипт выведет ссылку вида:

```text
tg://proxy?server=YOUR_IP&port=8443&secret=ee...
```

И сохранит её сюда:

```bash
/opt/telemt/link.txt
```

---

### ⚙️ Неинтерактивная установка

Обычная установка:

```bash
sudo bash telemt-installer.sh install --port 8443 --domain www.cloudflare.com
```

Установка с другим портом:

```bash
sudo bash telemt-installer.sh install --port 2096 --domain www.cloudflare.com
```

Установка с ad tag:

```bash
sudo bash telemt-installer.sh install \
  --port 8443 \
  --domain www.cloudflare.com \
  --ad-tag 1234567890abcdef1234567890abcdef
```

Установка без изменения UFW:

```bash
sudo bash telemt-installer.sh install --port 8443 --no-firewall
```

Полностью неинтерактивная установка с дефолтами:

```bash
sudo bash telemt-installer.sh install -y
```

---

### 📡 Популярные порты

Лучший порт обычно `443`, но он часто занят веб-сервером или другой нодой. Поэтому по умолчанию используется `8443`.

Рекомендуемый порядок:

```text
8443
2096
2087
2083
2053
```

Примеры:

```bash
sudo bash telemt-installer.sh install --port 8443
sudo bash telemt-installer.sh install --port 2096
sudo bash telemt-installer.sh install --port 2087
```

Не используй `443`, если не уверен на 100%, что он свободен.

Если очень надо:

```bash
sudo bash telemt-installer.sh install --port 443 --force-443
```

---

### 🔗 Показать ссылку

```bash
sudo bash telemt-installer.sh link
```

Или напрямую:

```bash
sudo cat /opt/telemt/link.txt
```

---

### 📊 Live monitor

Интерактивный монитор:

```bash
sudo bash telemt-installer.sh monitor
```

С обновлением раз в 1 секунду:

```bash
sudo bash telemt-installer.sh monitor --interval 1
```

Что показывает монитор:

```text
Active TCP connections
Active users/secrets
Active unique IPs
Estimated devices
Per-user traffic
Ad tag status
Active IP list
```

Важно: `Estimated devices` — это примерная оценка. Telegram может держать несколько TCP-соединений на одно устройство.

---

### 🏷️ Ad tag

`ad tag` нужен, если ты хочешь привязать прокси к `@MTProxybot`.

Требования:

```text
32 hex символа
пример: 1234567890abcdef1234567890abcdef
```

Указать при установке:

```bash
sudo bash telemt-installer.sh install --ad-tag 1234567890abcdef1234567890abcdef
```

Поменять после установки:

```bash
sudo bash telemt-installer.sh adtag
```

Удалить ad tag:

```bash
sudo bash telemt-installer.sh adtag
```

В интерактивном вводе напиши:

```text
-
```

---

### 🧰 Все команды

```bash
sudo bash telemt-installer.sh
```

```bash
sudo bash telemt-installer.sh install
```

```bash
sudo bash telemt-installer.sh install --port 8443 --domain www.cloudflare.com
```

```bash
sudo bash telemt-installer.sh install --port 2096 --domain www.microsoft.com
```

```bash
sudo bash telemt-installer.sh install --ad-tag 1234567890abcdef1234567890abcdef
```

```bash
sudo bash telemt-installer.sh monitor
```

```bash
sudo bash telemt-installer.sh monitor --interval 1
```

```bash
sudo bash telemt-installer.sh link
```

```bash
sudo bash telemt-installer.sh status
```

```bash
sudo bash telemt-installer.sh restart
```

```bash
sudo bash telemt-installer.sh adtag
```

```bash
sudo bash telemt-installer.sh uninstall
```

```bash
sudo bash telemt-installer.sh help
```

---

### 📁 Где что лежит

```text
/bin/telemt                         # бинарник Telemt
/etc/telemt/telemt.toml             # конфиг
/etc/systemd/system/telemt.service  # systemd service
/opt/telemt/secret.txt              # secret пользователя
/opt/telemt/link.txt                # готовая Telegram-ссылка
/opt/telemt/tlsfront                # директория TLS front/mask
```

---

### 🧪 Проверка работы

Статус сервиса:

```bash
sudo systemctl status telemt
```

Логи:

```bash
sudo journalctl -u telemt -n 100 --no-pager
```

Проверка порта:

```bash
sudo ss -ltnp | grep 8443
```

Проверка ссылки:

```bash
sudo bash telemt-installer.sh link
```

Проверка API локально:

```bash
curl -s http://127.0.0.1:9091/v1/users
```

---

### 🧯 Troubleshooting

#### Прокси не подключается в Telegram

Проверь порт:

```bash
sudo ss -ltnp | grep 8443
```

Проверь UFW:

```bash
sudo ufw status verbose
```

Проверь внешний firewall у VPS-провайдера. Очень часто порт открыт в Ubuntu, но закрыт в панели хостинга.

Проверь ссылку:

```bash
sudo bash telemt-installer.sh link
```

Удаляй старые прокси из Telegram полностью, а не редактируй старую запись.

---

#### Сервис не стартует

```bash
sudo systemctl status telemt
sudo journalctl -u telemt -n 100 --no-pager
```

Частые причины:

- порт уже занят;
- выбран порт `443`, а на нём уже nginx/Xray/Remnawave;
- не скачался бинарник Telemt;
- не поддерживается архитектура сервера;
- нет доступа к GitHub releases.

---

#### Порт занят

Посмотреть владельца:

```bash
sudo ss -ltnp | grep ':8443'
```

Выбери другой порт:

```bash
sudo bash telemt-installer.sh install --port 2096
```

---

#### Monitor показывает много подключений, хотя устройств мало

Это нормально. Telegram может открывать несколько TCP-соединений с одного устройства. Поэтому:

```text
connections ≠ devices
```

Ориентируйся на:

- `Active unique IPs`;
- `Active users/secrets`;
- примерную оценку `Estimated devices`.

---

#### Ad tag не принимается

Проверь, что он ровно 32 hex символа:

```text
0-9
a-f
A-F
```

Пример правильного тега:

```text
1234567890abcdef1234567890abcdef
```

---

### 🔒 Безопасность

- Не публикуй свой `secret`.
- Не публикуй рабочую ссылку, если не хочешь, чтобы прокси использовали посторонние.
- Файл `/opt/telemt/secret.txt` должен быть доступен только root/telemt.
- API Telemt слушает только `127.0.0.1:9091`.
- Скрипт не открывает API наружу.

---

### 🧹 Удаление

```bash
sudo bash telemt-installer.sh uninstall
```

Удаляется:

```text
/bin/telemt
/etc/telemt
/opt/telemt
/etc/systemd/system/telemt.service
user telemt
```

---

### 🧠 Почему Telemt, а не старый MTProxy?

Потому что старые Docker MTProxy-образы часто ведут себя странно: порт есть, пинг есть, а подключение висит. Telemt современнее, работает через FakeTLS, имеет API, статистику, нормальную конфигурацию и лучше подходит под реальные условия.

---

## 🌍 English

### What is this?

**Telemt MTProto Proxy Installer** is a clean one-file installer for running an MTProto proxy powered by **Telemt**.

It installs Telemt in **FakeTLS mode**, creates a systemd service, generates a Telegram proxy link, provides live connection monitoring, supports MTProxy ad tags, and can uninstall itself cleanly.

Made as a GitHub-ready installer: one `.sh` file, interactive menu, clear commands, minimal noise.

---

### ✨ Features

- ✅ Installs **Telemt MTProto Proxy** without Docker.
- ✅ Uses **FakeTLS** mode with `ee...` secrets.
- ✅ Clean interactive menu.
- ✅ Generates Telegram proxy links.
- ✅ Live monitor:
  - active TCP connections;
  - active IPs;
  - estimated devices;
  - per-user traffic;
  - ad tag status.
- ✅ Optional **ad tag** from `@MTProxybot`.
- ✅ Commands: `install`, `monitor`, `link`, `status`, `restart`, `adtag`, `uninstall`.
- ✅ Runs as a systemd service: `telemt`.
- ✅ Opens UFW automatically when UFW is active.
- ✅ Does not touch Docker containers.
- ✅ Refuses to use port `443` unless explicitly forced.

---

### ⚠️ Important notes

**This is not a Docker installer.**  
The script installs the Telemt binary and runs it through systemd.

**Port 443 is protected.**  
The installer refuses to use `443` unless `--force-443` is provided. This helps avoid breaking nginx, reverse proxies, Remnawave, Xray, or any existing node.

**Device count is estimated.**  
MTProto proxies do not see actual devices. They see TCP connections and IP addresses. One Telegram app may open multiple TCP connections, so the monitor shows an estimate.

**Ad tag is optional.**  
If you do not have a tag from `@MTProxybot`, leave it empty.

---

### 📦 Requirements

A normal Ubuntu/Debian VPS is enough.

Minimum:

- Ubuntu 20.04 / 22.04 / 24.04 or Debian 11/12;
- root access;
- `systemd`;
- an open TCP port, for example `8443`;
- `x86_64` or `aarch64` architecture.

The installer checks dependencies. If `curl` or `python3` is missing, it tries to install them via `apt`.

---

### 🚀 Quick start

Download the installer:

```bash
curl -fsSL https://raw.githubusercontent.com/n0tkaXD/mtproto-installer/main/telemt-installer.sh -o telemt-installer.sh
chmod +x telemt-installer.sh
sudo ./telemt-installer.sh
```

Or run the local file:

```bash
sudo bash telemt-installer.sh
```

---

Repository file link:

```text
https://github.com/n0tkaXD/mtproto-installer/blob/main/telemt-installer.sh
```

The `curl` command uses the raw URL because the GitHub `blob` page returns HTML, not the actual `.sh` file.

### 🧭 Interactive installation

```bash
sudo bash telemt-installer.sh
```

On first run, the installer asks:

```text
Proxy port [8443]:
FakeTLS domain [www.cloudflare.com]:
User name [main]:
Ad tag from @MTProxybot [empty = disabled]:
```

Recommended defaults:

```text
Port: 8443
FakeTLS domain: www.cloudflare.com
User name: main
Ad tag: empty unless you have one
```

After installation, the installer prints a link like:

```text
tg://proxy?server=YOUR_IP&port=8443&secret=ee...
```

It is saved here:

```bash
/opt/telemt/link.txt
```

---

### ⚙️ Non-interactive installation

Default install:

```bash
sudo bash telemt-installer.sh install --port 8443 --domain www.cloudflare.com
```

Different port:

```bash
sudo bash telemt-installer.sh install --port 2096 --domain www.cloudflare.com
```

Install with ad tag:

```bash
sudo bash telemt-installer.sh install \
  --port 8443 \
  --domain www.cloudflare.com \
  --ad-tag 1234567890abcdef1234567890abcdef
```

Skip UFW changes:

```bash
sudo bash telemt-installer.sh install --port 8443 --no-firewall
```

Fully non-interactive defaults:

```bash
sudo bash telemt-installer.sh install -y
```

---

### 📡 Recommended ports

Port `443` is usually the best from a network perspective, but it is often already used by a web server or another proxy node. This installer uses `8443` by default.

Recommended order:

```text
8443
2096
2087
2083
2053
```

Examples:

```bash
sudo bash telemt-installer.sh install --port 8443
sudo bash telemt-installer.sh install --port 2096
sudo bash telemt-installer.sh install --port 2087
```

Use `443` only if you are absolutely sure it is free:

```bash
sudo bash telemt-installer.sh install --port 443 --force-443
```

---

### 🔗 Show proxy link

```bash
sudo bash telemt-installer.sh link
```

Or directly:

```bash
sudo cat /opt/telemt/link.txt
```

---

### 📊 Live monitor

Interactive monitor:

```bash
sudo bash telemt-installer.sh monitor
```

Refresh every second:

```bash
sudo bash telemt-installer.sh monitor --interval 1
```

The monitor shows:

```text
Active TCP connections
Active users/secrets
Active unique IPs
Estimated devices
Per-user traffic
Ad tag status
Active IP list
```

Remember:

```text
connections ≠ devices
```

---

### 🏷️ Ad tag

The `ad tag` is used when you want to register your proxy through `@MTProxybot`.

Requirements:

```text
exactly 32 hex characters
example: 1234567890abcdef1234567890abcdef
```

Set it during install:

```bash
sudo bash telemt-installer.sh install --ad-tag 1234567890abcdef1234567890abcdef
```

Change it later:

```bash
sudo bash telemt-installer.sh adtag
```

Remove it:

```bash
sudo bash telemt-installer.sh adtag
```

Then type:

```text
-
```

---

### 🧰 All commands

```bash
sudo bash telemt-installer.sh
```

```bash
sudo bash telemt-installer.sh install
```

```bash
sudo bash telemt-installer.sh install --port 8443 --domain www.cloudflare.com
```

```bash
sudo bash telemt-installer.sh install --port 2096 --domain www.microsoft.com
```

```bash
sudo bash telemt-installer.sh install --ad-tag 1234567890abcdef1234567890abcdef
```

```bash
sudo bash telemt-installer.sh monitor
```

```bash
sudo bash telemt-installer.sh monitor --interval 1
```

```bash
sudo bash telemt-installer.sh link
```

```bash
sudo bash telemt-installer.sh status
```

```bash
sudo bash telemt-installer.sh restart
```

```bash
sudo bash telemt-installer.sh adtag
```

```bash
sudo bash telemt-installer.sh uninstall
```

```bash
sudo bash telemt-installer.sh help
```

---

### 📁 File locations

```text
/bin/telemt                         # Telemt binary
/etc/telemt/telemt.toml             # config
/etc/systemd/system/telemt.service  # systemd service
/opt/telemt/secret.txt              # user secret
/opt/telemt/link.txt                # generated Telegram link
/opt/telemt/tlsfront                # TLS front/mask directory
```

---

### 🧪 Health checks

Service status:

```bash
sudo systemctl status telemt
```

Logs:

```bash
sudo journalctl -u telemt -n 100 --no-pager
```

Port check:

```bash
sudo ss -ltnp | grep 8443
```

Proxy link:

```bash
sudo bash telemt-installer.sh link
```

Local API:

```bash
curl -s http://127.0.0.1:9091/v1/users
```

---

### 🧯 Troubleshooting

#### Telegram does not connect

Check the port:

```bash
sudo ss -ltnp | grep 8443
```

Check UFW:

```bash
sudo ufw status verbose
```

Also check your hosting provider’s firewall panel. The port may be open in Ubuntu but blocked outside the VPS.

Re-print the proxy link:

```bash
sudo bash telemt-installer.sh link
```

Remove old proxy entries from Telegram completely before adding the new one.

---

#### Service does not start

```bash
sudo systemctl status telemt
sudo journalctl -u telemt -n 100 --no-pager
```

Common causes:

- port already in use;
- port `443` already used by nginx/Xray/Remnawave;
- Telemt binary download failed;
- unsupported CPU architecture;
- GitHub releases are unreachable from the VPS.

---

#### Port is busy

Find the owner:

```bash
sudo ss -ltnp | grep ':8443'
```

Choose another port:

```bash
sudo bash telemt-installer.sh install --port 2096
```

---

#### Monitor shows many connections but few real devices

That is normal. Telegram may open several TCP connections from one app.

Use these values together:

- `Active unique IPs`;
- `Active users/secrets`;
- `Estimated devices`.

---

#### Ad tag is rejected

Make sure it is exactly 32 hexadecimal characters:

```text
0-9
a-f
A-F
```

Valid example:

```text
1234567890abcdef1234567890abcdef
```

---

### 🔒 Security

- Do not publish your secret.
- Do not publish your working proxy link unless you want others to use it.
- `/opt/telemt/secret.txt` should remain private.
- Telemt API listens only on `127.0.0.1:9091`.
- The installer does not expose the API publicly.

---

### 🧹 Uninstall

```bash
sudo bash telemt-installer.sh uninstall
```

Removed:

```text
/bin/telemt
/etc/telemt
/opt/telemt
/etc/systemd/system/telemt.service
user telemt
```

---

### 🧠 Why Telemt instead of old MTProxy?

Old MTProxy Docker images often behave badly: the port is open, Telegram sees ping, but the connection hangs forever. Telemt is newer, runs FakeTLS, has a useful API, exposes runtime statistics, and is easier to operate through systemd.

---

## 🌍 日本語

### これは何？

**Telemt MTProto Proxy Installer** は、**Telemt** を使って MTProto Proxy を簡単にセットアップするための、1ファイル構成のインストーラーです。

**FakeTLS モード**で動作し、systemd サービスを作成し、Telegram 用のプロキシリンクを生成します。さらに、接続状況のライブ監視、`ad tag` の設定、再起動、削除まで対応しています。

GitHub にそのまま置けるように作られた、シンプルで実用的なインストーラーです。

---

### ✨ 特徴

- ✅ **Telemt MTProto Proxy** を Docker なしでインストール。
- ✅ **FakeTLS** モードを使用。
- ✅ 見やすい対話式メニュー。
- ✅ Telegram 用プロキシリンクを自動生成。
- ✅ Live monitor:
  - アクティブな TCP 接続数;
  - アクティブな IP;
  - 推定デバイス数;
  - ユーザーごとの通信量;
  - ad tag 状態。
- ✅ `@MTProxybot` の **ad tag** に対応。
- ✅ `install`, `monitor`, `link`, `status`, `restart`, `adtag`, `uninstall` に対応。
- ✅ systemd サービス `telemt` として動作。
- ✅ UFW が有効な場合は必要なポートを開放。
- ✅ Docker コンテナには触れません。
- ✅ デフォルトでは `443` ポートを使用しません。

---

### ⚠️ 注意点

**これは Docker インストーラーではありません。**  
Telemt のバイナリをインストールし、systemd で起動します。

**ポート 443 は保護されています。**  
`--force-443` を指定しない限り、インストーラーは `443` を使いません。nginx、reverse proxy、Remnawave、Xray などを壊さないためです。

**デバイス数は推定です。**  
MTProto Proxy は実際の端末名や端末 ID を見ることはできません。見えるのは TCP 接続と IP アドレスです。Telegram アプリは 1台の端末でも複数の TCP 接続を開くことがあります。

**ad tag は任意です。**  
`@MTProxybot` のタグがない場合は空のままで問題ありません。

---

### 📦 必要環境

通常の Ubuntu/Debian VPS で十分です。

最小要件:

- Ubuntu 20.04 / 22.04 / 24.04 または Debian 11/12;
- root 権限;
- `systemd`;
- 開放された TCP ポート、例: `8443`;
- `x86_64` または `aarch64`。

`curl` や `python3` がない場合、インストーラーは `apt` でインストールを試みます。

---

### 🚀 クイックスタート

インストーラーをダウンロード:

```bash
curl -fsSL https://raw.githubusercontent.com/n0tkaXD/mtproto-installer/main/telemt-installer.sh -o telemt-installer.sh
chmod +x telemt-installer.sh
sudo ./telemt-installer.sh
```

またはローカルファイルを実行:

```bash
sudo bash telemt-installer.sh
```

---

リポジトリ内のファイルリンク:

```text
https://github.com/n0tkaXD/mtproto-installer/blob/main/telemt-installer.sh
```

`curl` コマンドでは raw URL を使います。GitHub の `blob` ページは `.sh` ファイル本体ではなく HTML を返すためです。

### 🧭 対話式インストール

```bash
sudo bash telemt-installer.sh
```

初回実行時に以下を聞かれます:

```text
Proxy port [8443]:
FakeTLS domain [www.cloudflare.com]:
User name [main]:
Ad tag from @MTProxybot [empty = disabled]:
```

おすすめ設定:

```text
Port: 8443
FakeTLS domain: www.cloudflare.com
User name: main
Ad tag: タグがなければ空欄
```

インストール後、以下のようなリンクが表示されます:

```text
tg://proxy?server=YOUR_IP&port=8443&secret=ee...
```

リンクはここにも保存されます:

```bash
/opt/telemt/link.txt
```

---

### ⚙️ 非対話式インストール

標準インストール:

```bash
sudo bash telemt-installer.sh install --port 8443 --domain www.cloudflare.com
```

別ポート:

```bash
sudo bash telemt-installer.sh install --port 2096 --domain www.cloudflare.com
```

ad tag 付き:

```bash
sudo bash telemt-installer.sh install \
  --port 8443 \
  --domain www.cloudflare.com \
  --ad-tag 1234567890abcdef1234567890abcdef
```

UFW を変更しない:

```bash
sudo bash telemt-installer.sh install --port 8443 --no-firewall
```

デフォルト値で完全非対話:

```bash
sudo bash telemt-installer.sh install -y
```

---

### 📡 おすすめポート

ネットワーク的には `443` が有利ですが、Web サーバーや他のプロキシで使われていることが多いため、デフォルトでは `8443` を使います。

おすすめ順:

```text
8443
2096
2087
2083
2053
```

例:

```bash
sudo bash telemt-installer.sh install --port 8443
sudo bash telemt-installer.sh install --port 2096
sudo bash telemt-installer.sh install --port 2087
```

`443` は本当に空いている場合だけ使ってください:

```bash
sudo bash telemt-installer.sh install --port 443 --force-443
```

---

### 🔗 リンクを表示

```bash
sudo bash telemt-installer.sh link
```

または直接:

```bash
sudo cat /opt/telemt/link.txt
```

---

### 📊 Live monitor

対話式モニター:

```bash
sudo bash telemt-installer.sh monitor
```

1秒ごとに更新:

```bash
sudo bash telemt-installer.sh monitor --interval 1
```

表示される情報:

```text
Active TCP connections
Active users/secrets
Active unique IPs
Estimated devices
Per-user traffic
Ad tag status
Active IP list
```

覚えておくこと:

```text
connections ≠ devices
```

---

### 🏷️ Ad tag

`ad tag` は `@MTProxybot` でプロキシを登録したい場合に使います。

条件:

```text
32文字の16進数
例: 1234567890abcdef1234567890abcdef
```

インストール時に指定:

```bash
sudo bash telemt-installer.sh install --ad-tag 1234567890abcdef1234567890abcdef
```

後から変更:

```bash
sudo bash telemt-installer.sh adtag
```

削除:

```bash
sudo bash telemt-installer.sh adtag
```

入力欄で以下を入力:

```text
-
```

---

### 🧰 全コマンド

```bash
sudo bash telemt-installer.sh
```

```bash
sudo bash telemt-installer.sh install
```

```bash
sudo bash telemt-installer.sh install --port 8443 --domain www.cloudflare.com
```

```bash
sudo bash telemt-installer.sh install --port 2096 --domain www.microsoft.com
```

```bash
sudo bash telemt-installer.sh install --ad-tag 1234567890abcdef1234567890abcdef
```

```bash
sudo bash telemt-installer.sh monitor
```

```bash
sudo bash telemt-installer.sh monitor --interval 1
```

```bash
sudo bash telemt-installer.sh link
```

```bash
sudo bash telemt-installer.sh status
```

```bash
sudo bash telemt-installer.sh restart
```

```bash
sudo bash telemt-installer.sh adtag
```

```bash
sudo bash telemt-installer.sh uninstall
```

```bash
sudo bash telemt-installer.sh help
```

---

### 📁 ファイルの場所

```text
/bin/telemt                         # Telemt バイナリ
/etc/telemt/telemt.toml             # 設定ファイル
/etc/systemd/system/telemt.service  # systemd サービス
/opt/telemt/secret.txt              # ユーザー secret
/opt/telemt/link.txt                # Telegram リンク
/opt/telemt/tlsfront                # TLS front/mask ディレクトリ
```

---

### 🧪 動作確認

サービス状態:

```bash
sudo systemctl status telemt
```

ログ:

```bash
sudo journalctl -u telemt -n 100 --no-pager
```

ポート確認:

```bash
sudo ss -ltnp | grep 8443
```

プロキシリンク:

```bash
sudo bash telemt-installer.sh link
```

ローカル API:

```bash
curl -s http://127.0.0.1:9091/v1/users
```

---

### 🧯 トラブルシューティング

#### Telegram が接続できない

ポート確認:

```bash
sudo ss -ltnp | grep 8443
```

UFW 確認:

```bash
sudo ufw status verbose
```

VPS プロバイダー側の firewall も確認してください。Ubuntu 側では開いていても、ホスティングパネル側で閉じていることがあります。

リンクを再表示:

```bash
sudo bash telemt-installer.sh link
```

Telegram の古いプロキシ設定は完全に削除してから、新しいリンクを追加してください。

---

#### サービスが起動しない

```bash
sudo systemctl status telemt
sudo journalctl -u telemt -n 100 --no-pager
```

よくある原因:

- ポートがすでに使われている;
- `443` が nginx/Xray/Remnawave に使われている;
- Telemt バイナリのダウンロード失敗;
- CPU アーキテクチャ非対応;
- VPS から GitHub releases にアクセスできない。

---

#### ポートが使用中

所有プロセスを見る:

```bash
sudo ss -ltnp | grep ':8443'
```

別ポートを使う:

```bash
sudo bash telemt-installer.sh install --port 2096
```

---

#### Monitor の接続数が多すぎる

正常です。Telegram は 1つのアプリから複数の TCP 接続を開くことがあります。

以下を組み合わせて見てください:

- `Active unique IPs`;
- `Active users/secrets`;
- `Estimated devices`.

---

#### Ad tag が拒否される

32文字の16進数か確認してください:

```text
0-9
a-f
A-F
```

正しい例:

```text
1234567890abcdef1234567890abcdef
```

---

### 🔒 セキュリティ

- secret を公開しないでください。
- 公開したくない場合はプロキシリンクも公開しないでください。
- `/opt/telemt/secret.txt` は安全に管理してください。
- Telemt API は `127.0.0.1:9091` のみで待ち受けます。
- API は外部に公開されません。

---

### 🧹 アンインストール

```bash
sudo bash telemt-installer.sh uninstall
```

削除されるもの:

```text
/bin/telemt
/etc/telemt
/opt/telemt
/etc/systemd/system/telemt.service
user telemt
```

---

### 🧠 なぜ古い MTProxy ではなく Telemt？

古い MTProxy Docker イメージでは、ポートは開いていて ping も見えるのに接続が永遠に終わらないことがあります。Telemt はより新しく、FakeTLS、API、統計情報、systemd 運用に対応しており、実運用しやすい構成です。

---

## ⭐ Credits

Made with chaos, caffeine and stubborn debugging.

**installer by n0tkaXD**
