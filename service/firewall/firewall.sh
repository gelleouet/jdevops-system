# Script pare-feu
#
# Utilise iptables pour bloquer les accès entrants et accepter les ports autorisés 
#
# Usage : firewall [start|stop|restart]
#
# @author Gregory Elleouet <gregory.elleouet@gmail.com>
#


#
# Demarre le parefeu
#
start()
{	
	# Bloquer tout le trafic (entrant/sortant)
	iptables -t filter -P INPUT DROP
	iptables -t filter -P FORWARD DROP
	iptables -t filter -P OUTPUT DROP
	
	# Conserver les connexions en cours
	iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
	iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
	
	# Localhost
	iptables -t filter -A INPUT -i lo -j ACCEPT
	iptables -t filter -A OUTPUT -o lo -j ACCEPT
	
	# SSH (par défaut juste sortant)
	iptables -t filter -A OUTPUT -p tcp --dport 22 -j ACCEPT
	
	# DNS
	iptables -t filter -A OUTPUT -p tcp --dport 53 -j ACCEPT
	iptables -t filter -A OUTPUT -p udp --dport 53 -j ACCEPT
	iptables -t filter -A INPUT -p tcp --dport 53 -j ACCEPT
	iptables -t filter -A INPUT -p udp --dport 53 -j ACCEPT
	
	# HTTP / HTTPS
	iptables -t filter -A OUTPUT -p tcp --dport 80 -j ACCEPT
	iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
	iptables -t filter -A OUTPUT -p tcp --dport 443 -j ACCEPT
	iptables -t filter -A INPUT -p tcp --dport 443 -j ACCEPT
	
	# autorisations speciales de l'exterieur
	if [ ! -z "$MYIP" ]; then
		iptables -t filter -A INPUT --source $MYIP/32 -j ACCEPT  
	fi
	
	return 0
}


#
# Arrete le parefeu
#
# Supprime toutes les règles du parefeu
# donc laisse passer tout le trafic
#
stop()
{	
	iptables -t filter -F
	iptables -t filter -X
	
	# rebasculer les politiques par défauts à accep sinon même en supprimant
	# les règles, tout sera bloqué
	iptables -P INPUT   ACCEPT
  	iptables -P FORWARD ACCEPT
  	iptables -P OUTPUT  ACCEPT
  	
	return 0
}


# execute action
case "$1" in
  start|restart)
    echo "Starting firewall..."
    stop
    start
    exit 0
    ;;
  stop)
    echo "Stopping firewall..."
    stop
    exit 0
    ;;
  *)
  	echo "Usage : firewall [start|stop|restart]"
  	exit 1
  	;;
esac