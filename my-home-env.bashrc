#--------------#
# Main aliases #
#--------------#

# Color
alias dir='dir --color=auto'
alias grep='grep --color=auto'
alias ls='ls --color=auto --group-directories-first' # add colors and file type extensions

# ls
alias ll='ls -lah'
alias lt='ls -laht'
alias ltr='ls -lahtr'
alias la='ls -A'

# Others
alias dmesg='dmesg -wxT --color=auto'
alias man='man -Pmore'
alias path='echo -e ${PATH//:/\\n}'
alias t="tmux"
alias myippub="wget -qO - icanhazip.com"


#-----#
# GIT #
#-----#

alias gitlog='git log -10 --oneline --graph --name-status'

function gitalias () {
  echo "" > ~/.bash_git_aliases
  for repo in $(find $HOME/git/* -name ".git" -printf '%h\n'); do echo "alias $(echo $repo | sed -e 's/^.*\/git\///' -e 's/\//_/g')=\"cd $repo && git pull\"" >> ~/.bash_git_aliases; done
  source ~/.bash_git_aliases
}

function gitremote () {
    git config --get remote.origin.url
    echo "https://$(git config --get remote.origin.url | sed -e 's/git@//' -e 's/:/\//' -e 's/.git$//')"
}


#------#
# X509 #
#------#

alias nmapssl="nmap --script ssl-enum-ciphers -p 443"

# Read x509 certificate request, certificate or key (auto-detect) and print modulus
function ossl () {
    # Header vars to identify the file type
    HEADER_KEY="PRIVATE KEY\-\-\-\-\-"
    HEADER_REQ="\-\-\-\-\-BEGIN CERTIFICATE REQUEST\-\-\-\-\-"
    HEADER_CRT="\-\-\-\-\-BEGIN CERTIFICATE\-\-\-\-\-"

    # Check if one parameter has been provided to this script
    if [ -z "$1" ]; then
      echo "ERROR: No argument supplied, please specify a unique CRT, CSR or KEY file (openssl compatible)."
    elif [ $# -ne 1 ]; then
        echo "ERROR: You must specify a unique parameter, please specify a unique CRT, CSR or KEY file (openssl compatible)."
    # Check if the file in argument exists
    elif [[ ! -f "$1" ]]; then
        echo "ERROR: The file $1 does not exist ! Please specify a unique CRT, CSR or KEY file (openssl compatible)."
    else

        # Check if header string exists in the file
        HEADER_KEY_RES=$(grep -c "$HEADER_KEY" $1)
        HEADER_REQ_RES=$(grep -c "$HEADER_REQ" $1)
        HEADER_CRT_RES=$(grep -c "$HEADER_CRT" $1)
        SUM_HEADER_RES=$(( $HEADER_KEY_RES + $HEADER_REQ_RES + $HEADER_CRT_RES ))

        # Check the file contains at least one type of header
        if [[ "$SUM_HEADER_RES" -eq 0 ]]; then
            echo "ERROR: the file does not contain KEY, REQ or CRT header, please specify a unique CRT, CSR or KEY file (openssl compatible)."
        else
            # Depends on the header found, use different openssl commands
            if [[ "$HEADER_CRT_RES" -gt 0 ]]; then
                openssl x509 -noout -text -in $1 | less
                echo "$1 modulus (md5sum): $(openssl x509 -noout -modulus -in $1 | md5sum)"
                echo "$1 main informations: $(openssl x509 -noout -subject -dates -issuer -email -in $1)"
            elif [[ "$HEADER_REQ_RES" -gt 0 ]]; then
                openssl req -noout -text -in $1 | less
                echo "$1 modulus (md5sum): $(openssl req -noout -modulus -in $1 | md5sum)"
                echo "$1 main informations: $(openssl req -noout -subject -in $1)"
            elif [[ "$HEADER_KEY_RES" -gt 0 ]]; then
                openssl rsa -noout -text -in $1 | less
                echo "$1 modulus (md5sum): $(openssl rsa -noout -modulus -in $1 | md5sum)"
            else
                echo "ERROR: the file does not contain KEY, REQ or CRT header, please specify a unique CRT, CSR or KEY file (openssl compatible)."
            fi
        fi
    fi
}

# Read x509 certificate from remote website and print modulus
function cssl () {
    # Check if one or two parameter(s) have been provided to this script
    if [ -z "$1" ]; then
      echo "ERROR: No argument supplied, please specify a HTTPS server to test in first parameter (ex : wikipedia.org or, localhost or an IP address) and optionally you can specify a servername in second parameter (ex: wikipedia.org)."
    elif [ $# -gt 2 ]; then
        echo "ERROR: More than 2 arguments supplied, please specify a HTTPS server to test in first parameter (ex : wikipedia.org or, localhost or an IP address) and optionally you can specify a servername (header HTTP Host) in second parameter (ex: wikipedia.org)."
    else
        # Depends on the number of parameter, specify servername or not in openssl s_client commands
        if [ $# -eq 1 ]; then
            echo "Q" | openssl s_client -connect $1:443 | openssl x509 -noout -text | less
            echo "Q" | openssl s_client -connect $1:443 | openssl x509 -noout -subject -issuer -email -dates
        elif [ $# -eq 2 ]; then
            echo "Q" | openssl s_client -connect $1:443 -servername $2 | openssl x509 -noout -text | less
            echo "Q" | openssl s_client -connect $1:443 -servername $2 | openssl x509 -noout -subject -issuer -email -dates
        else
            echo "ERROR: No argument supplied or more than 2 arguments supplied, please specify a HTTPS server to test in first parameter (ex : wikipedia.org or, localhost or an IP address) and optionally you can specify a servername in second parameter (ex: wikipedia.org)."
        fi
    fi
}

# Open a temp text file to paste an x509 element (crt, key, csr) and print info about it after you save the file
function osslt () {
    MYTEMPCERT=$(mktemp)
    vi $MYTEMPCERT
    ossl $MYTEMPCERT
    rm $MYTEMPCERT
}


#---------#
# Extract #
#---------#

# Extracts any archive(s) (if unp isn't installed)
function extract () {
    if [ -f $archive ] ; then
      case $archive in
        *.tar.bz2)   tar xvjf $archive    ;;
        *.tar.gz)    tar xvzf $archive    ;;
        *.bz2)       bunzip2 $archive     ;;
        *.rar)       rar x $archive       ;;
        *.gz)        gunzip $archive      ;;
        *.tar)       tar xvf $archive     ;;
        *.tbz2)      tar xvjf $archive    ;;
        *.tgz)       tar xvzf $archive    ;;
        *.zip)       unzip $archive       ;;
        *.Z)         uncompress $archive  ;;
        *.7z)        7za x $archive       ;;
        *.xz)        unxz $archive        ;;
        *.txz)       tar Jxvf $archive    ;;
        *)           echo "don't know how to extract '$archive'..." ;;
      esac
    else
      echo "'$archive' is not a valid file!"
    fi
}

#---------#
# History #
#---------#

HISTSIZE= HISTSIZEFILE= #infinite history

# Eliminate duplicates across the whole history
export HISTCONTROL=ignoreboth:erasedups
# Add Date and Time to Bash History : day/month/year - hour :
export HISTTIMEFORMAT="%d %m %y %T "

# Store multi-line commands in one history entry:
shopt -s cmdhist
# Resizable terminal support
shopt -s checkwinsize
# Update the values of LINES and COLUMNS.
shopt -s histappend


#-----#
# PS1 #
#-----#

# Function used to configure PS1 (see after)
git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Configure PS1
PS1="\n\[\033[01;34m\]\w\[\033[00m\]\n\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]$ "
#PS1="\n\h:\[\e[33m\]\w\[\e[m\] " # path in color
PS1="\n\h:\[\033[01;34m\]\w\[\033[00m\] "
#PS1+="📂 \$(find . -mindepth 1 -maxdepth 1 -type d | wc -l) " # print number of folders
#PS1+="📄 \$(find . -mindepth 1 -maxdepth 1 -type f | wc -l) " # print number of files
#PS1+="🔗 \$(find . -mindepth 1 -maxdepth 1 -type l | wc -l) " # print number of symlinks
PS1+="\$(git_branch)\n" # jump to new line
PS1+="\u \[\e[1;31m\]\A\[\e[0m\] "
export PS1


#------------#
# Kubernetes #
#------------#

alias k=kubectl
complete -F __start_kubectl k


#-----------------#
# Other functions #
#-----------------#

# Function to print basic server informations about a remote SSH host
function proto () {

  if [ -z "$2" ]; then

    ssh $1 '
      function custom_get_web_config () {
        for vhost_config in $(ls -p $1 | grep -v /); do
          if [[ -f "$1/$vhost_config" ]]; then
            echo "$1/${vhost_config}:"
            grep -i -e \<VirtualHost -e server_name -e servername -e serveralias $1/${vhost_config} | sed -r -e "s/[\t]*//" -e "s/^ *//g" -e "s/^server/    server/i" -e "s/<VirtualHost/  <VirtualHost/i"
            echo ""
          fi
        done
      }

      echo "--------------------------"
      echo "HOSTNAME: $(hostname --fqdn)"
      echo "IP addresses:"
      hostname -I | awk "{print $1}"
      echo "--------------------------"
      echo "OS/KERNEL INFO"
      uname -a
      if [ -f /etc/os-release ]; then
        grep -v http /etc/os-release
      fi
      echo "--------------------------"
      echo "PORTS (other than SSH, SMTP, Zabbix):"
      netstat -lntp | grep -v -e "0.0.0.0:10050 " -e ":::10050 " -e "127.0.0.53:53 " -e "0.0.0.0:25 " -e "0.0.0.0:22 " -e  ":::22 " -e ":::25 " -e "0.0.0.0:5666 " -e ":::5666 " -e "::1:25 " -e "127.0.0.1:25 " -e "0.0.0.0:111 " -e ":::111"
      echo "--------------------------"
      echo "UPTIME:"
      uptime
      echo -e "--------------------------\n"

      echo "--------------------------"
      echo "LOAD AVERAGE:"
      cat /proc/loadavg
      echo "--------------------------"
      echo "Process using the most CPU:"
      ps aux --sort=-pcpu | head -n 6
      echo -e "--------------------------\n"

      echo "--------------------------"
      echo "MEMORY UTILIZATION:"
      free -h
      echo "--------------------------"
      echo "Process using the most MEMORY:"
      ps aux --sort -rss | head -6
      echo -e "--------------------------\n"

      nb_more_than_80_percent_storage=$(df -h | awk "\$5>80 {print}" | wc -l)
      nb_more_than_80_percent_inodes=$(df -ih | awk "\$5>80 {print}" | wc -l)

      if [ "$nb_more_than_80_percent_storage" -gt 1 ] || [ "$nb_more_than_80_percent_inodes" -gt 1 ]; then
        if [ "$nb_more_than_80_percent_storage" -gt 1 ]; then
          echo "--------------------------"
          echo "STORAGE filled to equal or more than 80%:"
          df -h | awk "\$5>80 {print}"
        fi
        if [ "$nb_more_than_80_percent_inodes" -gt 1 ]; then
          echo "--------------------------"
          echo "INODES filled to equal or more than 80%:"
          df -hi | awk "\$5>80 {print}"
        fi
        echo -e "--------------------------\n"
      fi

      if [[ "$(w|wc -l)" -gt 2 ]]; then
        echo "--------------------------"
        echo "USERS connected:"
        w
        echo -e "--------------------------\n"
      fi

      which varnishadm
      if [[ "$?" -eq 0 ]]; then
        echo "--------------------------"
        echo "VARNISH Backends status:"
        sudo varnishadm backend.list
        echo -e "--------------------------\n"
      fi

      if [[ -d "/etc/nginx" ]]; then
        if [[ -d "/etc/nginx/sites-enabled" ]]; then
          echo "--------------------------"
          echo -e "NGINX config in /etc/nginx/sites-enabled\n"
          custom_get_web_config /etc/nginx/sites-enabled
          echo -e "--------------------------\n"
        fi
      fi

      if [[ -d "/etc/apache" ]]; then
        if [[ -d "/etc/apache/sites-enabled" ]]; then
          echo "--------------------------"
          echo -e "APACHE HTTPD config in /etc/apache/sites-enabled\n"
          custom_get_web_config /etc/apache/sites-enabled
          echo -e "--------------------------\n"
        fi
      fi

      if [[ -d "/etc/apache2" ]]; then
        if [[ -d "/etc/apache2/sites-enabled" ]]; then
          echo "--------------------------"
          echo -e "APACHE HTTPD config in /etc/apache2/sites-enabled\n"
          custom_get_web_config /etc/apache2/sites-enabled
          echo -e "--------------------------\n"
        fi
      fi

      if [[ -d "/etc/httpd" ]]; then
        if [[ -d "/etc/httpd/sites-enabled" ]]; then
          echo "--------------------------"
          echo -e "APACHE HTTPD config in /etc/httpd/sites-enabled\n"
          custom_get_web_config /etc/httpd/sites-enabled
          echo -e "--------------------------\n"
        fi
      fi

    ' | less

  else

    ssh $1 '

      VHOST_CONFIG_FILE='"$2"'

      echo "--------------------------"
      echo "HOSTNAME: $(hostname --fqdn)"
      echo "IP addresses:"
      hostname -I | awk "{print $1}"
      echo -e "--------------------------\n"

      echo "--------------------------"
      echo "Vhost config file: $VHOST_CONFIG_FILE"

      if [[ -f "$VHOST_CONFIG_FILE" ]]; then
        grep -i -e \<VirtualHost -e server_name -e servername -e serveralias $VHOST_CONFIG_FILE | sed -r -e "s/[\t]*//" -e "s/^ *//g" -e "s/^server/    server/i" -e "s/<VirtualHost/  <VirtualHost/i"
        ACCESS_LOG_FILE=$(grep -i -o /.*access.*log $VHOST_CONFIG_FILE)
        ERROR_LOG_FILE=$(grep -i -o /.*error.*log $VHOST_CONFIG_FILE)
        DOCUMENTROOT=$(grep -i -e "root " $VHOST_CONFIG_FILE)

        echo $DOCUMENTROOT

        if sudo test -e "$ACCESS_LOG_FILE"; then
          echo "--------------------------"
          echo "Access log file: $ACCESS_LOG_FILE"
          sudo cut -d" " -f1 $ACCESS_LOG_FILE | sort | uniq -c | sort -nr | head -n 10
        fi

        if sudo test -e $ERROR_LOG_FILE; then
          echo "--------------------------"
          echo "Errors log file: $ERROR_LOG_FILE"
        fi

      else
        echo "ERROR: the vhost config file $VHOST_CONFIG_FILE does not exist"
      fi
      echo -e "--------------------------\n"

    ' | less

  fi

}


# Function to print vhost hosted on a remote SSH host
function protoweb () {

    ssh $1 '
      function custom_get_web_config () {
        for vhost_config in $(ls -p $1 | grep -v /); do
          if [[ -f "$1/$vhost_config" ]]; then
            echo "$1/${vhost_config}:"
            grep -i -e \<VirtualHost -e server_name -e servername -e serveralias $1/${vhost_config} | sed -r -e "s/[\t]*//" -e "s/^ *//g" -e "s/^server/    server/i" -e "s/<VirtualHost/  <VirtualHost/i"
            echo ""
          fi
        done
      }

      if [[ -d "/etc/nginx" ]]; then
        if [[ -d "/etc/nginx/sites-enabled" ]]; then
          echo "--------------------------"
          echo -e "NGINX config in /etc/nginx/sites-enabled\n"
          custom_get_web_config /etc/nginx/sites-enabled
          echo -e "--------------------------\n"
        fi
      fi

      if [[ -d "/etc/apache" ]]; then
        if [[ -d "/etc/apache/sites-enabled" ]]; then
          echo "--------------------------"
          echo -e "APACHE HTTPD config in /etc/apache/sites-enabled\n"
          custom_get_web_config /etc/apache/sites-enabled
          echo -e "--------------------------\n"
        fi
      fi

      if [[ -d "/etc/apache2" ]]; then
        if [[ -d "/etc/apache2/sites-enabled" ]]; then
          echo "--------------------------"
          echo -e "APACHE HTTPD config in /etc/apache2/sites-enabled\n"
          custom_get_web_config /etc/apache2/sites-enabled
          echo -e "--------------------------\n"
        fi
      fi

      if [[ -d "/etc/httpd" ]]; then
        if [[ -d "/etc/httpd/sites-enabled" ]]; then
          echo "--------------------------"
          echo -e "APACHE HTTPD config in /etc/httpd/sites-enabled\n"
          custom_get_web_config /etc/httpd/sites-enabled
          echo -e "--------------------------\n"
        fi
      fi

    ' | less
}
