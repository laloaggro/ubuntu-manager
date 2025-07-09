#!/bin/bash

# ==============================================
#       SUPER UBUNTU ULTIMATE MANAGER v5.0
# ==============================================
# Versión: 5.0
# Autor: laloaggro
# Contacto: laloaggro@gmail.com
# Repositorio: https://github.com/laloaggro/ubuntu-manager
# Licencia: MIT
# ==============================================

# ---- Configuración inicial ----
# Colores para la interfaz
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Variables configurables
CONFIG_DIR="$HOME/.config/ubuntu-manager"
BACKUP_DIR="$CONFIG_DIR/backups"
LOG_FILE="$CONFIG_DIR/ubuntu-manager.log"
CONFIG_FILE="$CONFIG_DIR/config.conf"
VERSION="5.0"
AUTHOR="laloaggro"
CONTACT="laloaggro@gmail.com"
REPO="https://github.com/laloaggro/ubuntu-manager"

# Crear directorios de configuración si no existen
mkdir -p "$CONFIG_DIR" "$BACKUP_DIR"

# Configuración inicial si no existe
if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" <<EOL
# Configuración Ubuntu Manager
AUTO_UPDATE=1
BACKUP_ENABLED=1
THEME=default
EOL
fi
source "$CONFIG_FILE"

# ---- Funciones básicas ----
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

pause() {
    echo -e "${BLUE}\nPresiona Enter para continuar...${NC}"
    read -r
}

show_header() {
    clear
    echo -e "${YELLOW}============================================${NC}"
    echo -e "${MAGENTA}   SUPER UBUNTU ULTIMATE MANAGER v$VERSION    ${NC}"
    echo -e "${CYAN}          Autor: $AUTHOR            ${NC}"
    echo -e "${BLUE}       Contacto: $CONTACT        ${NC}"
    echo -e "${GREEN}    Repositorio: $REPO    ${NC}"
    echo -e "${YELLOW}============================================${NC}\n"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Este comando requiere privilegios root. Usa 'sudo'.${NC}"
        return 1
    fi
    return 0
}

# ---- Funciones del sistema ----
system_update() {
    show_header
    echo -e "${YELLOW}[ ACTUALIZACIÓN DEL SISTEMA ]${NC}"
    log "Iniciando actualización del sistema"
    
    echo -e "\n${CYAN}Actualizando lista de paquetes...${NC}"
    sudo apt update | tee -a "$LOG_FILE"
    
    echo -e "\n${CYAN}Actualizando paquetes...${NC}"
    sudo apt upgrade -y | tee -a "$LOG_FILE"
    
    echo -e "\n${CYAN}Limpiando paquetes innecesarios...${NC}"
    sudo apt autoremove -y | tee -a "$LOG_FILE"
    
    log "Actualización completada"
    echo -e "\n${GREEN}✅ Sistema actualizado correctamente${NC}"
    pause
}

security_scan() {
    show_header
    echo -e "${YELLOW}[ HERRAMIENTAS DE SEGURIDAD ]${NC}"
    
    echo -e "\n${CYAN}=== Escaneo de puertos abiertos ===${NC}"
    sudo netstat -tulnp
    
    echo -e "\n${CYAN}=== Servicios activos ===${NC}"
    sudo systemctl list-units --type=service --state=running
    
    echo -e "\n${CYAN}=== Archivos con permisos especiales ===${NC}"
    sudo find / -type f \( -perm -4000 -o -perm -2000 \) -exec ls -l {} \; 2>/dev/null | head -n 20
    
    echo -e "\n${CYAN}=== Estado del firewall ===${NC}"
    sudo ufw status verbose
    
    pause
}

network_tools() {
    while true; do
        show_header
        echo -e "${YELLOW}[ HERRAMIENTAS DE RED ]${NC}"
        echo -e "1) ${GREEN}Información de red${NC}"
        echo -e "2) ${GREEN}Escanear redes WiFi${NC}"
        echo -e "3) ${GREEN}Prueba de velocidad${NC}"
        echo -e "4) ${GREEN}Diagnóstico de conexión${NC}"
        echo -e "5) ${GREEN}Volver al menú principal${NC}"
        
        read -p "Selecciona una opción (1-5): " choice
        
        case $choice in
            1)
                echo -e "\n${CYAN}=== Información de interfaces de red ===${NC}"
                ip a
                ;;
            2)
                echo -e "\n${CYAN}=== Escaneo de redes WiFi disponibles ===${NC}"
                sudo iwlist wlan0 scan | grep ESSID
                ;;
            3)
                echo -e "\n${CYAN}=== Ejecutando prueba de velocidad ===${NC}"
                if ! command -v speedtest-cli &> /dev/null; then
                    sudo apt install speedtest-cli -y
                fi
                speedtest-cli --simple
                ;;
            4)
                echo -e "\n${CYAN}=== Diagnóstico de conexión a Internet ===${NC}"
                ping -c 4 google.com
                traceroute google.com -m 5
                ;;
            5)
                break
                ;;
            *)
                echo -e "${RED}Opción no válida${NC}"
                ;;
        esac
        pause
    done
}

# ---- Menú principal ----
main_menu() {
    while true; do
        show_header
        echo -e "${CYAN} MENÚ PRINCIPAL ${NC}"
        echo -e "1) ${GREEN}Actualización del sistema${NC}"
        echo -e "2) ${GREEN}Herramientas de seguridad${NC}"
        echo -e "3) ${GREEN}Herramientas de red${NC}"
        echo -e "4) ${GREEN}Salir${NC}"
        
        read -p "Selecciona una opción (1-4): " choice
        
        case $choice in
            1) system_update ;;
            2) security_scan ;;
            3) network_tools ;;
            4)
                echo -e "\n${GREEN}¡Gracias por usar Ubuntu Manager!${NC}"
                echo -e "${BLUE}Para más herramientas visita: $REPO ${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Opción no válida${NC}"
                pause
                ;;
        esac
    done
}

# ---- Inicio del script ----
trap "echo -e '\n${RED}Script interrumpido. Saliendo...${NC}'; exit 1" SIGINT SIGTERM

clear
echo -e "${YELLOW}Iniciando Ubuntu Manager v$VERSION...${NC}"
echo -e "${CYAN}Desarrollado por: $AUTHOR${NC}"
echo -e "${BLUE}Contacto: $CONTACT${NC}"
sleep 2

main_menu
