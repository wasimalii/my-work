# final scipt
#!/bin/bash
# note:- please download dev_installer.tar.gz and spl_iterators.h from your google drive before executing this script.
set -e # exit if error occur in script
set -x # for tracing cmd in script

# Installing homebrew
if [[ $(command -v brew) == "" ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
else
  echo "Homebrew is already installed"
fi
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/$(whoami)/.zprofile
if [ $SHELL == "/bin/bash" ] 
then
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/$(whoami)/.bashrc
else    
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/$(whoami)/.zshrc
fi    
source ~/.zprofile

# updating homebrew
brew update

# installing required package for setup
brew install apr c-ares gd jemalloc libffi libsodium openldap python@3.9 tidy-html5    
brew install zookeeper kafka pcre2 sqlite apr-util ca-certificates gdbm jpeg libidn2 libssh2 nghttp2    
brew install openssl@1.1 readline unixodbc zstd wget autoconf freetds pkg-config telnet zlib    
brew install argon2 curl gettext libmemcached libtiff nginx pcre rtmpdump webp aspell fontconfig glib krb5 libmetalink    
brew install libtool  gmp libev libpng libunistring oniguruma tcl-tk xz brotli freetype icu4c libevent libpq libzip openjdk  
brew install zlib pcre pcre2 golang
brew tap shivammathur/php    
brew install shivammathur/php/php@7.4    
brew link php@7.4 

# checking the processor is M1 chip or not.
arch=$(sysctl machdep.cpu.brand_string)   
chip=$(echo "$arch" | cut -d ' ' -f 3)  

# condition where the processor chip is M1 or not and shell is bash or zsh  
if [[ $chip == "M1" && $SHELL == "/bin/bash" ]] 
then 
    echo "export PATH='/opt/homebrew/opt/php@7.4/bin:/opt/homebrew/opt/php@7.4/sbin:$PATH'" >> ~/.bashrc
    echo 'export PATH="/opt/homebrew/opt/node@14/bin:$PATH"' >> ~/.bashrc
    echo 'requirepass rCB3bB7Vq1ZX' >> /opt/homebrew/etc/redis.conf
    source ~/.bashrc
elif [[ $chip != "M1" && $SHELL == "/bin/bash" ]]
then
    cd /usr/local/Cellar/php@7.4/
    php_version=$(ls)
    echo "export PATH='/usr/local/Cellar/php@7.4/$php_version/bin:/usr/local/Cellar/php@7.4/$php_version/sbin:$PATH'" >> ~/.bashrc
    echo 'export PATH="/usr/local/Cellar/node@14/bin:$PATH"' >> ~/.bashrc
    echo 'requirepass rCB3bB7Vq1ZX' >> /usr/local/etc/redis.conf 
    source ~/.bashrc
elif [[ $chip == "M1" && $SHELL == "/bin/zsh" ]]
then
    echo "export PATH='/opt/homebrew/opt/php@7.4/bin:/opt/homebrew/opt/php@7.4/sbin:$PATH'" >> ~/.zshrc
    echo 'export PATH="/opt/homebrew/opt/node@14/bin:$PATH"' >> ~/.zshrc
    echo 'requirepass rCB3bB7Vq1ZX' >> /opt/homebrew/etc/redis.conf
    source ~/.zshrc
else [[ $chip != "M1" && $SHELL == "/bin/zsh" ]]   
    cd /usr/local/Cellar/php@7.4/
    php_version=$(ls)         
    echo "export PATH='/usr/local/Cellar/php@7.4/$php_version/bin:/usr/local/Cellar/php@7.4/$php_version/sbin:$PATH'" >> ~/.zshrc
    echo 'export PATH="/usr/local/Cellar/node@14/bin:$PATH"' >> ~/.zshrc
    echo 'requirepass rCB3bB7Vq1ZX' >> /usr/local/etc/redis.conf 
    source ~/.zshrc
fi

# extracting mongodb tar 
tar -xzf /Users/$(whoami)/Downloads/dev_installer.tar -C /Users/$(whoami)/  
# if shell is bash then creating alias in .bashrc
if [ $SHELL == "/bin/bash" ] 
then
    echo "alias start:mongodb:rs0='/Users/$(whoami)/_INSTALL/mongo-rs/init.sh'" >> ~/.bashrc
    echo "alias connect:mongodb:rs0='/Users/$(whoami)/_INSTALL/mongo-rs/bin/mongo "mongodb://127.0.0.1:27018,127.0.0.1:27019,127.0.0.1:27020/?replicaSet=rs0"'" >> ~/.bashrc
    echo "alias start:mongodb:rs1='/Users/$(whoami)/_INSTALL/mongo-rs1/init.sh'" >> ~/.bashrc
    echo "alias connect:mongodb:rs1='/Users/$(whoami)/_INSTALL/mongo-rs1/bin/mongo "mongodb://127.0.0.1:27021,127.0.0.1:27022,127.0.0.1:27023/?replicaSet=rs1"'" >> ~/.bashrc
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
    echo '[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm' >> ~/.bashrc
    echo '[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"' >> ~/.bashrc
    echo "export GOPATH=$HOME/go" >> ~/.bashrc
    echo 'export GOROOT="$(brew --prefix golang)/libexec"' >> ~/.bashrc
    echo 'export PATH="$PATH:${GOPATH}/bin:${GOROOT}"' >> ~/.bashrc
    source ~/.bashrc
else  # ifshell is zsh then setting alias in .zshrc
    echo "alias start:mongodb:rs0='/Users/$(whoami)/_INSTALL/mongo-rs/init.sh'" >> ~/.zshrc
    echo "alias start:mongodb:rs1='/Users/$(whoami)/_INSTALL/mongo-rs1/init.sh'" >> ~/.zshrc
    echo "alias connect:mongodb:rs0='/Users/$(whoami)/_INSTALL/mongo-rs/bin/mongo "mongodb://127.0.0.1:27018,127.0.0.1:27019,127.0.0.1:27020/?replicaSet=rs0"'" >> ~/.zshrc
    echo "alias connect:mongodb:rs1='/Users/$(whoami)/_INSTALL/mongo-rs1/bin/mongo "mongodb://127.0.0.1:27021,127.0.0.1:27022,127.0.0.1:27023/?replicaSet=rs1"'" >> ~/.zshrc  
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
    echo '[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm' >> ~/.zshrc
    echo '[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"' >> ~/.zshrc
    echo "export GOPATH=$HOME/go" >> ~/.zshrc
    echo 'export GOROOT="$(brew --prefix golang)/libexec"' >> ~/.zshrc
    echo 'export PATH="$PATH:${GOPATH}/bin:${GOROOT}"' >> ~/.zshrc
    source ~/.zshrc 
fi

# intalling node and golang
brew install nvm golang    
source ~/.zshrc
nvm install 14 
npm install pm2 -g 
npm install --global yarn 
cd ~
source ~/.zshrc
brew services start php@7.4
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mkdir /usr/local/bin
sudo mv composer.phar /usr/local/bin/composer

# creating the link between files 
if [[ $chip == "M1" ]] 
then 
    pcre2_version=$(ls /opt/homebrew/Cellar/pcre2/)
    php_version=$(ls /opt/homebrew/Cellar/php@7.4/)
    cd ~
    mv /opt/homebrew/Cellar/php@7.4/$php_version/include/php/ext/pcre/php_pcre.h .    
    ln -s /opt/homebrew/Cellar/pcre2/$pcre2_version/include/pcre2.h /opt/homebrew/Cellar/php@7.4/$php_version/include/php/ext/pcre/php_pcre.h
    cp /Users/$(whoami)/Downloads/spl_iterators.h /opt/homebrew/Cellar/php@7.4/$php_version/include/php/ext/spl/spl_iterators.h
else 
    pcre2_version=$(ls /usr/local/Cellar/pcre2/)
    php_version=$(ls /usr/local/Cellar/php@7.4/)
    cd ~    
    mv /usr/local/Cellar/php@7.4/$php_version/include/php/ext/pcre/php_pcre.h .
    ln -s /usr/local/Cellar/pcre2/$pcre2_version/include/pcre2.h /usr/local/Cellar/php@7.4/$php_version/include/php/ext/pcre/php_pcre.h   
    cp /Users/$(whoami)/Downloads/spl_iterators.h /usr/local/Cellar/php@7.4/$php_version/include/php/ext/spl/spl_iterators.h
fi
pecl install mongodb
pecl install redis

# appending extension to the php.ini file
if [[ $chip == "M1" ]] 
then 
    echo 'extension="memcached.so"'  >> /opt/homebrew/etc/php/7.4/php.ini
    echo 'extension="mongodb.so"'  >> /opt/homebrew/etc/php/7.4/php.ini
else 
    echo 'extension="memcached.so"'  >> /usr/local/etc/php/7.4/php.ini
    echo 'extension="mongodb.so"'  >> /usr/local/etc/php/7.4/php.ini
fi

# Installing memcached for caching objects 
cd ~
pecl bundle memcached
cd memcached

#  preparing the build environment for a PHP extension.
phpize
chip=M1
if [[ $chip == "M1" ]] 
then
    cd /opt/homebrew/Cellar/zlib/
    zlib_version=$(ls)
    cd -
    yes | ./configure --with-zlib-dir=/opt/homebrew/Cellar/zlib/$zlib_version
else
    cd /usr/local/Cellar/zlib/
    zlib_version=$(ls)
    cd -
    yes | ./configure --with-zlib-dir=/usr/local/Cellar/zlib/$zlib_version
fi

# make command build and maintain groups of programs and files from the source code. 
make

# installs the program by copying the binaries as defined by ./configure 
make install

# starting services
brew install nginx redis memcached 
brew tap altinity/clickhouse    
brew install clickhouse   
brew services start redis
brew services start memcached
brew services start php@7.4
brew services start nginx
brew services start zookeeper
brew services start kafka
brew services start clickhouse
