# Дипломный практикум в Yandex.Cloud Алавидзе И.Г.
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
2. Подготовьте [backend](https://developer.hashicorp.com/terraform/language/backend) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)
3. Создайте конфигурацию Terrafrom, используя созданный бакет ранее как бекенд для хранения стейт файла. Конфигурации Terraform для создания сервисного аккаунта и бакета и основной инфраструктуры следует сохранить в разных папках.
4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://developer.hashicorp.com/terraform/language/backend) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий, стейт основной конфигурации сохраняется в бакете или Terraform Cloud
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

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

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).

### Деплой инфраструктуры в terraform pipeline

1. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ на 80 порту к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ на 80 порту к тестовому приложению.
5. Atlantis или terraform cloud или ci/cd-terraform
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

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

---



#  Дипломный практикум в Yandex.Cloud

**Автор:** Алавидзе И.Г.  
**Дата:** Сентябрь 2026  
**Облачный провайдер:** Yandex Cloud  
**Репозиторий:** [github.com/irakool5-wq/yandex-cloud-devops-diplom](https://github.com/irakool5-wq/yandex-cloud-devops-diplom)

---

## 1. Создание облачной инфраструктуры

**Цель этапа:**  
Первичная подготовка облачной среды в Yandex Cloud для дальнейшего развертывания инфраструктуры с использованием Terraform (Infrastructure as Code).

**Используемые инструменты:**
- **Terraform** — инструмент управления инфраструктурой как кодом (IaC).
- **Yandex Cloud CLI (`yc`)** — инструмент управления облаком.
- **Yandex Cloud IAM** — система управления доступом.
- **Yandex Object Storage** — для хранения state-файла Terraform (S3 backend).

**Описание реализованной инфраструктуры:**  
Проект разделен на две логические директории для соблюдения принципа разделения ответственности:
- `setup/` — создание сервисного аккаунта и S3-бакета для хранения стейта.
- `infra/` — основная инфраструктура (VPC, подсети, Kubernetes, Registry, Bastion).

### 1.1. Сервисный аккаунт и IAM
Создан сервисный аккаунт `terraform`.

### 1.2. Конфигурация Backend
Для хранения состояния Terraform настроен S3-совместимый backend в файле `infra/backend.tf`:
```hcl
terraform {
  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket   = "alavidze-tf-state-b1gtud25o2pff6srffhu"
    region   = "ru-central1"
    key      = "terraform.tfstate"
    
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}


### 1.3. Сетевая инфраструктура (VPC)

Создана виртуальная сеть `alavidze-develop-24-01` с подсетями в трех зонах доступности для обеспечения отказоустойчивости:

- **Публичные подсети:**
  - `public-ru-central1-a`
  - `public-ru-central1-b`
  - `public-ru-central1-d`

- **Приватные подсети:**
  - `private-ru-central1-a`
  - `private-ru-central1-b`
  - `private-ru-central1-d`

✅ **Результаты выполнения этапа:**

- [x] Создан сервисный аккаунт `terraform`..
- [x] Настроен S3 backend для хранения state-файла.
- [x] Создана VPC с подсетями в 3 зонах доступности.
- [x] Конфигурация позволяет выполнять `terraform apply` и `terraform destroy` без ручных вмешательств.


## 2. Создание Kubernetes кластера

**Цель этапа:**  
Развернуть работоспособный Kubernetes кластер на базе предварительно созданной сетевой инфраструктуры с обеспечением доступа из Интернета.
<img width="1235" height="174" alt="Скриншот 27-09-2026 145721" src="https://github.com/user-attachments/assets/2d346ed1-85f8-4d5a-b4a9-ecd6e57ade64" />
<img width="1235" height="174" alt="Скриншот 27-09-2026 145721" src="https://github.com/user-attachments/assets/45f4b947-2055-425d-95a1-a5599682223c" />

**Выбранный вариант:** Альтернативный (рекомендуемый методикой) — использование сервиса **Yandex Managed Service for Kubernetes**.

**Используемые инструменты:**
- **Terraform** (`yandex_kubernetes_cluster`, `yandex_kubernetes_node_group`)
- **kubectl** — для управления кластером.

### 2.1. Конфигурация кластера (`infra/k8s.tf`)

Создан региональный мастер-кластер и группа узлов со следующими параметрами:

- **Master:** Региональный, публичный IP-адрес включен.
- **Node Group:** 2 прерываемые (preemptible) виртуальные машины для экономии бюджета.
- **Платформа:** `standard-v3` (2 vCPU, 4 GB RAM на ноду).
- **Распределение:** Узлы размещены в 3 разных подсетях (`ru-central1-a`, `ru-central1-b`, `ru-central1-d`).
- **Сеть:** В конфигурации `network_interface` включен параметр `nat = true` для обеспечения прямого выхода узлов в Интернет (необходимо для скачивания образов из Docker Hub).

✅ **Результаты выполнения этапа:**

- [x] Работоспособный Managed Kubernetes кластер.
- [x] В файле `~/.kube/config` находятся данные для доступа.
- [x] Команда `kubectl get nodes` отрабатывает без ошибок, показывая 2 узла в статусе `Ready`.

---

<img width="1235" height="174" alt="Скриншот 27-09-2026 145721" src="https://github.com/user-attachments/assets/014b2368-5e74-45a9-a477-c898cf8a41ef" />


<img width="1548" height="771" alt="Скриншот 27-09-2026 165105" src="https://github.com/user-attachments/assets/aa41b0e1-7fd3-4d62-97b3-2d32a402d051" />




## 3. Создание тестового приложения

**Цель этапа:**  
Подготовить тестовое приложение, упаковать его в Docker-образ и опубликовать в Yandex Container Registry.

**Используемые инструменты:**
- **Docker** — контейнеризация приложения.
- **Git / GitHub** — хранение исходного кода и версионирование.
- **Yandex Container Registry** — хранение Docker-образов (создан через Terraform).

### 3.1. Структура и код

В репозитории создана директория `app/` со следующей структурой:

```text
app/
├── Dockerfile
└── index.html

**Dockerfile:**

```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]


**index.html:**  
Содержит статическую страницу с текстом: *"Дипломный практикум в Yandex.Cloud / Алавидзе И.Г."*

### ✅ Результаты выполнения этапа

- ✅ Git-репозиторий содержит исходный код приложения и Dockerfile.
- ✅ Образ успешно собирается и отправляется в Yandex Container Registry (`cr.yandex/<registry_id>/diploma-app`).


## 4. Подготовка системы мониторинга и деплой приложения

**Цель этапа:**  
Задеплоить в кластер Prometheus, Grafana, Alertmanager, Node Exporter, а также развернуть тестовое приложение с HTTP-доступом на 80 порту.

**Используемые инструменты:**
- **Helm** — пакетный менеджер для Kubernetes.
- **kube-prometheus-stack** (Prometheus Community) — готовый набор чартов для мониторинга.
- **kubectl** — для управления кластером.

### 4.1. Деплой системы мониторинга

Использован готовый Helm-чарт, включающий все необходимые компоненты:

```bash
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.service.type=LoadBalancer \
  --set grafana.service.port=80 \
  --set grafana.adminPassword=admin


> 💡 **Архитектурное решение:** Сервис Grafana настроен как `LoadBalancer` на порту `80`, что полностью удовлетворяет требованию методички о HTTP-доступе без необходимости использования SSH-туннелей.

### 4.2. Деплой тестового приложения

В директории `k8s/app/` созданы манифесты `deployment.yaml` и `service.yaml`. Сервис приложения также имеет тип `LoadBalancer` и слушает порт `80`.

### ✅ Результаты выполнения этапа

- ✅ Все поды в namespace `monitoring` находятся в статусе `Running`.
- ✅ HTTP-доступ к веб-интерфейсу Grafana на 80 порту (логин: `admin`, пароль: `admin`).
- ✅ Дашборд "Kubernetes / Compute Resources / Nodes" отображает реальные метрики CPU и памяти.
- ✅ HTTP-доступ к тестовому приложению на 80 порту.



<img width="1574" height="833" alt="Скриншот 27-09-2026 145546" src="https://github.com/user-attachments/assets/b8c3a7d1-f185-4a0a-926d-e63e60a462fb" />

<img width="1805" height="761" alt="Скриншот 27-09-2026 145333" src="https://github.com/user-attachments/assets/7634dc58-9bbb-4ba7-b80d-4f82ea75ea28" />


## 5. Установка и настройка CI/CD

**Цель этапа:**  
Настроить автоматическую сборку Docker-образа и деплой приложения при изменении кода, а также автоматизировать применение конфигурации Terraform через CI/CD-систему.

**Выбранная CI/CD-система:** **GitHub Actions** (альтернативный вариант из методички: вместо Terraform Cloud или Atlantis настроить автоматический запуск и применение конфигурации Terraform из git-репозитория в CI/CD-системе при любом комите в `main` ветку).

**Используемые инструменты:**
- **GitHub Actions** — CI/CD-система для автоматизации.
- **Yandex Cloud CLI** — устанавливается динамически в раннере через `curl`.

### 5.1. Пайплайн деплоя приложения (`ci-cd.yml`)

**Необходимые секреты GitHub:**

| Секрет | Описание |
|--------|----------|
| `YC_SA_KEY` | JSON ключ сервисного аккаунта |
| `YC_FOLDER_ID` | ID каталога Yandex Cloud |
| `YC_REGISTRY_ID` | ID Container Registry |
| `YC_CLUSTER_ID` | ID Kubernetes кластера |

**Триггер:** Push тега (например, `v1.0.0`).

**Шаги пайплайна:**
1. 📥 Checkout кода из репозитория.
2. ️ Установка Yandex Cloud CLI через `curl`.
3. 🔑 Аутентификация через сервисный ключ (`YC_SA_KEY`).
4. 🐳 Настройка Docker для работы с Yandex Container Registry.
5. ️ Сборка Docker-образа с тегом версии.
6. 📤 Push образа в Yandex Container Registry.
7. 🔌 Получение credentials Kubernetes кластера.
8.  Обновление манифеста `deployment.yaml` (замена тега образа).
9. 🚀 Деплой в Kubernetes через `kubectl apply`.

### ✅ Результаты выполнения этапа

- ✅ При создании тега происходит сборка, отправка образа в Registry и деплой в Kubernetes.
- ✅ Интерфейс CI/CD (GitHub Actions) доступен и показывает выполнение пайплайнов.



<img width="1548" height="771" alt="Скриншот 27-09-2026 165105" src="https://github.com/user-attachments/assets/a781792e-1418-4b2a-b17a-1f374af29446" />








