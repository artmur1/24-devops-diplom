# Дипломный практикум в Yandex.Cloud - `Мурчин Артем`
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)
3. Создайте конфигурацию Terrafrom, используя созданный бакет ранее как бекенд для хранения стейт файла. Конфигурации Terraform для создания сервисного аккаунта и бакета и основной инфраструктуры следует сохранить в разных папках.
4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий, стейт основной конфигурации сохраняется в бакете или Terraform Cloud
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

### Решение. Создание облачной инфраструктуры

Конфигурация терраформ для создания инфраструктуры. Бакет в ЯО.

provider.tf - https://github.com/artmur1/24-devops-diplom/blob/main/files/terraform/provider.tf

bucket.tf - https://github.com/artmur1/24-devops-diplom/blob/main/files/terraform/bucket.tf

infrastructure.tf - https://github.com/artmur1/24-devops-diplom/blob/main/files/terraform/infrastructure.tf

service_account.tf - https://github.com/artmur1/24-devops-diplom/blob/main/files/terraform/service_account.tf

locals.tf - https://github.com/artmur1/24-devops-diplom/blob/main/files/terraform/locals.tf

variables.tf - https://github.com/artmur1/24-devops-diplom/blob/main/files/terraform/variables.tf

Стейт файл - https://github.com/artmur1/24-devops-diplom/blob/main/files/terraform/images/kitten1.jpg

---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

### Решение. Создание Kubernetes кластера

Через терраформ в ЯО создал 3 ВМ на Ubuntu 24.04.

k8s_cluster.tf - https://github.com/artmur1/24-devops-diplom/blob/main/files/terraform/k8s_cluster.tf

meta.yml - https://github.com/artmur1/24-devops-diplom/blob/main/files/terraform/meta.yml

Задеплоил Kubernetes на подготовленные ранее инстансы с помощью Kubespray. В git у Kubespray появилась новая ветка, делал с переключением на нее, а затем снова в main, чтобы запустить ансибл. Также указал версию кубернетес для установки 1.29.0, т.к. по умолчанию в Kubespray указана 1.21.0. Но в процессе дальнейшего изучения на сайте Oracle узнал, что лучше ставить на Ubuntu 24.04 версию 1.31.1.

Команды для установки Kubespray:

    sudo apt update
    sudo apt install git python3 python3-pip -y
    git clone https://github.com/kubernetes-sigs/kubespray
    cd kubespray
    git checkout release-2.17
    https://linuxcapable.com/install-python-3-12-on-ubuntu-linux/ - установка python3.12-venv в ubuntu 20.04
    sudo apt install python3.12-venv - создаем виртуальное окружение
    
    python3 -m venv .venv
    source .venv/bin/activate
    
    python3 -m pip install -r requirements.txt
    cp -rfp inventory/sample inventory/mycluster
    declare -a IPS=(192.168.20.13 192.168.20.11 192.168.20.36) - задаем воркер ноды в кластер
    
    pip3 install ruamel.yaml
    CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
    nano inventory/mycluster/hosts.yaml
    nano inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml - указать устанавливаемую версию kubernetes
    
    git checkout master
    python3 -m pip install -r requirements.txt
    ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml -b -v &
    
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    
    kubectl get nodes
    kubectl get pods --all-namespaces

Файл hosts.yaml:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/d-k8s-1-1.png)

Указал версию k8s в файлеk8s-cluster.yml:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/d-k8s-1-2.png)

файл `~/.kube/config`:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/d-k8s-1-4.png)

После выполнения данных команд Кубернетес был установлен. Кластер работает. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/d-k8s-1-3.png)

---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

### Решение. Создание тестового приложения

Создал отдельный git репозиторий https://github.com/artmur1/24-nginx

nginx конфиг - https://github.com/artmur1/24-nginx/blob/main/nginx.conf

статические данные - https://github.com/artmur1/24-nginx/blob/main/index.html

Dockerfile - https://github.com/artmur1/24-nginx/blob/main/Dockerfile

Получился примитивный Dockerfile. Собрал docker image. 

Регистри с собранным docker image на DockerHub:

    docker push artmur18/diplom-nginx:1.0.0

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).

2. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ на 80 порту к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ на 80 порту к тестовому приложению.

### Решение. Подготовка cистемы мониторинга и деплой приложения

Для установки пакета kube-prometheus, включающего в себя Kubernetes оператор для grafana, prometheus, alertmanager, node_exporter, воспользовался следующей документацией:

https://github.com/prometheus-operator/kube-prometheus/blob/main/docs/customizing.md

Установку призводил на master-node1. В процессе установки был установлен golang и добавлен каталог go в $PATH следующей командой:

    $ export PATH=$PATH:$(go env GOPATH)/bin

Также для компиляции был установлен gojsontoyaml и jsonnet и снова ввел вышеуказанную команду.

Настройки и конфигурацию приложений оставил по умолчанию. Далее выполнил сборку:

    ./build.sh example.jsonnet

Далее применил стек kube-prometheus:

    $ kubectl apply --server-side -f manifests/setup
    $ kubectl apply -f manifests/

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/d-pro-1-1.png)

Видно, что в k8s поднялись и работают новые поды: prometheus-operator, grafana, prometheus, alertmanager, node_exporter.

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/d-pro-1-2.png)

Далее занялся деплоем и настройкой в кластере atlantis. Настройку производил по следующей документации:

https://www.runatlantis.io/docs/installation-guide.html

Пользователя в github использвал текущего. На сайте https://www.browserling.com/tools/random-string сгенерировал Webhook Secret. Далее перешел в Deployment. Начал с выполнения инструкции Kubernetes Helm Chart. Отредактировал values.yaml. Внес свои данные user, token, secret, orgAllowlist. Остальные настройки в values.yaml оставил без изменеий:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/d-pro-1-5.png)

values.yaml - https://github.com/artmur1/24-devops-diplom/blob/main/files/atlantis/values.yaml

Установл helm. Запустил установку values.yaml:

    helm install atlantis runatlantis/atlantis -f values.yaml

Далее приступил к установке Kubernetes Manifests. Выполнил команды:

    echo -n "yourtoken" > token
    echo -n "yoursecret" > webhook-secret
    kubectl create secret generic atlantis-vcs --from-file=token --from-file=webhook-secret

Внес свои данные в Deployment Manifest:

Deployment Manifest - https://github.com/artmur1/24-devops-diplom/blob/main/files/atlantis/deployment.yaml

Один под atlantis запустился, а второй в ожидании чего-то..

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/d-pro-1-3.png)

Описание пода в ожидании:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/d-pro-1-4.png)

Пробовал подключится к порту 4141 - ничего нет.

#### Продожение выполнения пункта "Подготовка cистемы мониторинга и деплой приложения"

При установке атлантис уперся в то, что для деплоя кластера нужен атлантис, для деплоя атлантиса нужен кластер. Потому дальнейшие работы по атлантису приостановил и решил деплоить кластер из github action. Через terraform снес старую инфраструктуру и развернул заново kubernetes cluster. На этот раз установил kubernetes версии 1.31.4.

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/helm-prometheus-k8s-1.png)

Установку cистемы мониторинга решил производсть через helm. Для начала установил helm:

    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    sudo apt-get install apt-transport-https --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm

Добавил репозиторий prometheus-community и скачал файл с настройками prometheus:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/helm-prometheus-1.png)

Запустил установку cистемы мониторинга с указанием файла с настройками:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/helm-prometheus-4.png)

Видно, что сервисы и поды grafana, prometheus, alertmanager и node_exporter успешно запустились:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/helm-prometheus-5.png)

Беру пароль из файла с настройками:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/helm-prometheus-6.png)

Страничка с графаной успешно загружается. Ввожу логин и пароль:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/helm-prometheus-7.png)

Успешно авторизовался, добавил метрики:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/helm-prometheus-8.png)

Для развертывания тестового приложения в кластер написал deployment.yaml - https://github.com/artmur1/24-devops-diplom/blob/main/files/k8s/deployment.yaml

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/test-prilogenie-9.png)

Создал namespace и запустил деплоймент:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/test-prilogenie-10.png)

Подключился к поду, curl localhost возвращает содержимое index.html - приложение развернуто в кластере и работает!

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/test-prilogenie-11.png)

Далее, чтобы приложение было доступно по внешнему адресу на определенном порту, написал service.yaml:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/test-prilogenie-12.png)

Применил service.yaml. Теперь приложение доступно на внешнем порту 31030:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/test-prilogenie-13.png)

Приложение успешно загрузилось на внешнем адресе!

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/test-prilogenie-14.png)



---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

### Решение. Установка и настройка CI/CD

Выполнять настройки ci/cd системы для автоматической сборки docker image и деплоя приложения при изменении кода буду в GitHub Action. Внес в репозиторий https://github.com/artmur1/24-nginx данные для входа в учетную запись dockerhub. Также добавил данные для подключения к кластеру через kubectl:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/ci-cd-01.png)

Написал ci-cd.yaml для автоматической сборки docker image и деплоя приложения - https://github.com/artmur1/24-nginx/blob/main/.github/workflows/ci-cd.yaml:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/ci-cd-02.png)

Создал namespace netology:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/ci-cd-03.png)

Отредактировал index.html и написал в коммите комментарий v1.2.10 и отправил ветку main в репозиторий:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/ci-cd-04.png)

Автоматическая сборка docker image v1.2.10 и деплой приложения в кластер прошли успешно:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/ci-cd-05.png)

Отредактировал index.html прописав в коммите комментарий v1.2.11, и Deployment.yaml указав номер теге приложения v1.2.11. Отправил ветку main в репозиторий:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/ci-cd-06.png)

Автоматическая сборка docker image с новым тегом v1.2.11 и деплой приложения в кластер прошли успешно:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/ci-cd-07.png)

Образы на докерхабе:

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/ci-cd-08.png)

Ссылка на action - https://github.com/artmur1/24-nginx/actions/runs/12995097915

![](https://github.com/artmur1/24-devops-diplom/blob/main/img/ci-cd-09.png)

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

