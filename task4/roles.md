|Роль|	Полномочия|	Группы пользователей|
|---|---|---|
|cluster-admin|	Полный доступ ко всем ресурсам кластера|	Администраторы системы, SRE|
|namespace-admin|	Полный доступ ко всем ресурсам в namespace|	Team Leads, DevOps инженеры|
|developer|	Чтение/запись в specific namespace, кроме чувствительных ресурсов|	Разработчики приложений|
|viewer|Только чтение во всех namespaces|	Бизнес-аналитики, QA|
|ci-bot|Деployment в specific namespaces, чтение логов|	CI/CD системы|
|security-auditor|Чтение всех ресурсов, доступ к security contexts|	Security team|