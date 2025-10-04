#!/bin/bash
USER="safalkon"
REMOTE="safalkon@192.168.10.26:/home/safalkon/backup"
SSH_KEY="/home/safalkon/.ssh/id_ed25519"
KEEP_COUNT=5

# Создаем бэкап
backup_name="backup-$(date +%Y-%m-%d-%H%M%S)"
echo "Создание бэкапа: $backup_name"

ssh -i "$SSH_KEY" "$(echo $REMOTE | cut -d: -f1)" \
    "mkdir -p $(echo $REMOTE | cut -d: -f2)"

# Бэкап
rsync -av --delete --link-dest="../current" \
    -e "ssh -i $SSH_KEY" \
    "/home/$USER/" \
    "$REMOTE/$backup_name/"

# Обновляем симлинк
ssh -i "$SSH_KEY" "$(echo $REMOTE | cut -d: -f1)" \
    "cd $(echo $REMOTE | cut -d: -f2) && rm -f current && ln -s $backup_name current"

echo "Бэкап создан: $backup_name"

# УДАЛЕНИЕ
echo "Очистка старых бэкапов..."

ssh -i "$SSH_KEY" "$(echo $REMOTE | cut -d: -f1)" \
    "cd $(echo $REMOTE | cut -d: -f2) && \
     ls -1d backup-* 2>/dev/null | sort -r | tail -n +$((KEEP_COUNT + 1)) | xargs -r rm -rf"

echo "Готово"

# Проверка
echo "Оставшиеся бэкапы:"
ssh -i "$SSH_KEY" "$(echo $REMOTE | cut -d: -f1)" \
    "cd $(echo $REMOTE | cut -d: -f2) && ls -1d backup-* 2>/dev/null | sort -r"