#!/bin/bash

# ==============================================
#       SUPER UBUNTU ULTIMATE MANAGER v5.1
# ==============================================
# Versión: 5.1
# Autor: laloaggro
# Contacto: laloaggro@gmail.com
# Repositorio: https://github.com/laloaggro/ubuntu-manager
# Licencia: MIT
# Descripción: Suite completa de gestión para Ubuntu
# ==============================================

# ---- Configuración inicial ----
# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Variables configurables
BACKUP_DIR="$HOME/Backups"
LOG_FILE="/var/log/ubuntu_manager.log"
CONFIG_FILE="$HOME/.ubuntu_manager.conf"
SNAPSHOT_DIR="$HOME/system_snapshots"
VERSION="5.0"
AUTHOR="l4l0ag2r0"

# Crear directorios necesarios
mkdir -p "$BACKUP_DIR" "$SNAPSHOT_DIR"

# Cargar configuración
if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" <<EOL
# Configuración SUPER UBUNTU MANAGER
AUTO_UPDATE=1
BACKUP_ENABLED=1
MONITOR_INTERVAL=60
THEME=default
EOL
fi
source "$CONFIG_FILE"

# ---- Funciones de utilidad ----
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

pause() {
    echo -e "${BLUE}\nPresiona Enter para continuar...${NC}"
    read -r
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Este comando requiere privilegios root. Usa 'sudo'.${NC}"
        return 1
    fi
    return 0
}

spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

show_header() {
    clear
    echo -e "${YELLOW}============================================${NC}"
    echo -e "${MAGENTA}   SUPER UBUNTU ULTIMATE MANAGER v$VERSION    ${NC}"
    echo -e "${CYAN}          Autor: $AUTHOR            ${NC}"
    echo -e "${YELLOW}============================================${NC}"
}

# ---- Funciones principales ----
system_update() {
    show_header
    echo -e "\n${YELLOW}[ ACTUALIZACIÓN DEL SISTEMA ]${NC}"
    log "Iniciando actualización del sistema"
    
    sudo apt update | tee -a "$LOG_FILE" &
    spinner
    sudo apt upgrade -y | tee -a "$LOG_FILE" &
    spinner
    sudo apt autoremove -y | tee -a "$LOG_FILE" &
    spinner
    
    log "${GREEN}Actualización completada${NC}"
    echo -e "\n${GREEN}✅ Sistema actualizado${NC}"
    pause
}

security_scan() {
    show_header
    echo -e "\n${YELLOW}[ ESCANEO DE SEGURIDAD AVANZADO ]${NC}"
    
    echo -e "${CYAN}\n=== Puertos abiertos ===${NC}"
    sudo netstat -tulnp
    
    echo -e "${CYAN}\n=== Servicios activos ==="
    sudo systemctl list-units --type=service --state=running
    
    echo -e "${CYAN}\n=== Archivos con permisos SUID ==="
    sudo find / -type f -perm -4000 2>/dev/null | head -n 20
    
    echo -e "${CYAN}\n=== Usuarios con acceso root ==="
    sudo grep -Po '^sudo.+:\K.*$' /etc/group
    
    echo -e "${CYAN}\n=== Verificación de firewall ==="
    sudo ufw status verbose
    
    pause
}

network_tools() {
    while true; do
        show_header
        echo -e "\n${YELLOW}[ HERRAMIENTAS DE RED ]${NC}"
        echo -e "1) ${GREEN}Configuración de red${NC}"
        echo -e "2) ${GREEN}Escaneo WiFi${NC}"
        echo -e "3) ${GREEN}Prueba de velocidad${NC}"
        echo -e "4) ${GREEN}Diagnóstico de red${NC}"
        echo -e "5) ${GREEN}Volver al menú principal${NC}"
        
        read -rp "Selecciona una opción (1-5): " net_choice
        
        case $net_choice in
            1)
                echo -e "\n${CYAN}=== CONFIGURACIÓN DE RED ===${NC}"
                ip a
                ;;
            2)
                echo -e "\n${CYAN}=== ESCANEO WIFI ===${NC}"
                sudo iwlist scan | grep ESSID
                ;;
            3)
                echo -e "\n${CYAN}=== PRUEBA DE VELOCIDAD ===${NC}"
                sudo apt install speedtest-cli -y
                speedtest-cli
                ;;
            4)
                echo -e "\n${CYAN}=== DIAGNÓSTICO DE RED ===${NC}"
                ping -c 4 google.com
                traceroute google.com
                ;;
            5)
                break
                ;;
            *)
                echo -e "${RED}Opción inválida${NC}"
                ;;
        esac
        pause
    done
}

# ---- Menú principal ----
main_menu() {
    while true; do
        show_header
        echo -e "\n${CYAN} MENÚ PRINCIPAL ${NC}"
        echo -e "1) ${GREEN}Actualización del sistema${NC}"
        echo -e "2) ${GREEN}Herramientas de seguridad${NC}"
        echo -e "3) ${GREEN}Herramientas de red${NC}"
        echo -e "4) ${GREEN}Configuración${NC}"
        echo -e "5) ${GREEN}Salir${NC}"
        
        read -rp "Selecciona una opción (1-5): " main_choice
        
        case $main_choice in
            1) system_update ;;
            2) security_scan ;;
            3) network_tools ;;
            4) config_menu ;;
            5)
                echo -e "\n${GREEN}¡Hasta luego! 👋${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Opción inválida${NC}"
                pause
                ;;
        esac
    done
}

# ---- Inicio del script ----
trap "echo -e '\n${RED}Script interrumpido. Saliendo...${NC}'; exit 1" SIGINT SIGTERM

clear
echo -e "${YELLOW}Cargando SUPER UBUNTU ULTIMATE MANAGER v$VERSION...${NC}"
echo -e "${CYAN}Desarrollado por $AUTHOR${NC}"
sleep 2

main_menu
