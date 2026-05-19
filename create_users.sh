#!/bin/bash

# Kontrollera att scriptet körs som root
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Scriptet måste köras som root."
    exit 1 
fi

if [ "$#" -eq 0 ]; then
    echo "Fel: Ange minst ett användarnamn."
    echo "Exempel: sudo ./create_users.sh Anna Bjorn Charlie"
    exit 1
fi

# Skapa först alla användare
for username in "$@"; do

if id "$username" &>/dev/null; then
    echo "Användaren $username finns redan."
else
    useradd -m "$username"
fi

    # Skapa mappar
    mkdir -p "/home/$username/Documents"
    mkdir -p "/home/$username/Downloads"
    mkdir -p "/home/$username/Work"

    # Sätt ägare
    chown -R "$username:$username" "/home/$username"

    # Endast ägaren får läsa, skriva och öppna mapparna
    chmod 700 "/home/$username/Documents"
    chmod 700 "/home/$username/Downloads"
    chmod 700 "/home/$username/Work"
done

# Skapa EFTER att alla användare finns
for username in "$@"; do

    echo "Välkommen $username" > "/home/$username/welcome.txt"

    # Lista alla andra användare i systemet
    awk -F: '$3 >= 1000 && $1 != "'"$username"'" { print $1 }' /etc/passwd >> "/home/$username/welcome.txt"


    # Sätt rätt ägare och rättighet på filen
    chown "$username:$username" "/home/$username/welcome.txt"
    chmod 600 "/home/$username/welcome.txt"
done