#!/bin/bash
USER="safalkon"
REMOTE="safalkon@192.168.10.26:/home/safalkon/backup"
SSH_KEY="/home/safalkon/.ssh/id_ed25519"

echo "ВОССТАНОВЛЕНИЕ С ПЕРЕЗАПИСЬЮ"
echo "ВНИМАНИЕ: Это перезапишет текущие файлы!"
echo

backups=$(ssh -i "$SSH_KEY" "$(echo $REMOTE | cut -d: -f1)" \
    "cd $(echo $REMOTE | cut -d: -f2) && ls -1d backup-* 2>/dev/null | sort -r")

if [ -z "$backups" ]; then
    echo "Бэкапы не найдены!"
    exit 1
fi

echo "Доступные бэкапы:"
i=1
for backup in $backups; do
    echo "$i. $backup"
    i=$((i+1))
done

echo
read -p "Выберите номер бэкапа: " num

if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt $((i-1)) ]; then
    echo "Неверный номер!"
    exit 1
fi

selected_backup=$(echo "$backups" | sed -n "${num}p")

echo
echo "ВЫ УВЕРЕНЫ? Это перезапишет файлы в /home/$USER/"
read -p "Напишите 'y' для подтверждения: " confirm

if [ "$confirm" != "y" ]; then
    echo "Отменено"
    exit 1
fi

echo "Восстанавливаем $selected_backup..."
rsync -av --delete \
    -e "ssh -i $SSH_KEY" \
    "$REMOTE/$selected_backup/" \
    "/home/$USER/"

echo "Восстановление завершено!"
