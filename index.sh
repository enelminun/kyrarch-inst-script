#!/bin/bash

# Kullanıcı dil seçimi
echo "Lütfen dil seçin (tr/en): "
read language

# Dil dosyasını seçme
if [ "$language" == "aze" ]; then
    lang_file="Lang_AZB.klf"
if [ "$language" == "tr" ]; then
    lang_file="Lang_TR.klf"
elif [ "$language" == "en" ]; then
    lang_file="Lang_EN.klf"
else
    echo "Geçersiz dil seçimi. Varsayılan olarak İngilizce kullanılacak."
    lang_file="Lang_EN.klf"
fi

# Dil dosyasından metin okuma fonksiyonu
get_text() {
    grep -i "$1" "$lang_file" | cut -d '=' -f2
}

# Dil dosyasındaki metinleri al
greeting=$(get_text "greeting")
desktop_question=$(get_text "desktop_question")
aur_question=$(get_text "aur_question")
minimal_question=$(get_text "minimal_question")
ollama_question=$(get_text "ollama_question")
mpv_question=$(get_text "mpv_question")
ani_tools_question=$(get_text "ani_tools_question")

# Kullanıcıya masaüstü ortamı sorusu
echo "$desktop_question"
echo "1) KDE-PLASMA"
echo "2) XFCE4"
echo "3) Gnome"
read desktop_choice

case $desktop_choice in
    1) desktop="kde-plasma" ;;
    2) desktop="xfce4" ;;
    3) desktop="gnome" ;;
    *) echo "Geçersiz seçim."; exit 1 ;;
esac

# AUR kurulum tercihi
echo "$aur_question"
echo "1) Pikaur"
echo "2) Yay"
echo "3) Hayır"
read aur_choice

case $aur_choice in
    1) aur="pikaur" ;;
    2) aur="yay" ;;
    3) aur="no" ;;
    *) echo "Geçersiz seçim."; exit 1 ;;
esac

# Minimal kurulum tercihi
echo "$minimal_question"
echo "yes / no"
read minimal_choice

if [ "$minimal_choice" == "yes" ]; then
    minimal=true
else
    minimal=false
fi

# Ollama, OpenWebUI ve Docker kurulum tercihi (AUR kullanımı ve minimal kurulum durumu kontrolü)
if [ "$aur" != "no" ] && [ "$minimal" == false ]; then
    echo "$ollama_question"
    read ollama_choice
    if [ "$ollama_choice" == "yes" ]; then
        echo "Ollama ve Docker kuruluyor..."
        yay -S ollama docker --no-confirm
        sudo systemctl enable --now ollama
        sudo systemctl enable --now docker
        docker pull ghcr.io/open-webui/open-webui:main
        docker run -d -p 3000:8080 -v open-webui:/app/backend/data --name open-webui ghcr.io/open-webui/open-webui:main
    fi
fi

# Ortam oynatıcıları kurulacak mı sorusu
if [ "$minimal" == false ]; then
    echo "$mpv_question"
    read mpv_choice
    if [ "$mpv_choice" == "yes" ]; then
        sudo pacman -S mpv --noconfirm
    fi
fi

# Ani-tools (ani-cli) kurulacak mı sorusu
if [ "$minimal" == false ]; then
    echo "$ani_tools_question"
    read ani_tools_choice
    if [ "$ani_tools_choice" == "yes" ]; then
        yay -S ani-cli --noconfirm
    fi
fi

# Masaüstü ortamı kurulumu
echo "Masaüstü ortamı kuruluyor: $desktop..."
sudo pacman -S $desktop --no-confirm
