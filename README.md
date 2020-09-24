# create-virtual-host-ubuntu
This Project help all create virtual host for ubuntu quickly and easy 


Это сценарий оболочки, который создает новый виртуальный хост для заданного имени без необходимости проходить весь процесс.

Монтаж
Загрузите сценарий в папку, /usr/local/binа шаблон - в папку /etc/apache2/sites-available.

1)git clone https://github.com/Ashot1995/create-virtual-host-ubuntu.git

2)cd  create-virtual-host-ubuntu

3)sudo cp create-project.sh /usr/local/bin

4)sudo cp template /etc/apache2/sites-available


Вы можете переименовать и файл.chmodcreate-project.sh

sudo mv /usr/local/bin/create-project.sh /usr/local/bin/create-project && sudo chmod +x /usr/local/bin/create-project

использование
Чтобы увидеть инструкции по использованию, просто запустите create-project --help
