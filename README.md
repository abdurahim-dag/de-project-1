# Проект 1

### Описание
Репозиторий предназначен для сдачи проекта №1.

### Как работать с репозиторием
1. В вашем GitHub-аккаунте автоматически создастся репозиторий `de-project-1` после того, как вы привяжете свой GitHub-аккаунт на Платформе.
2. Скопируйте репозиторий на свой компьютер. В качестве пароля укажите ваш `Access Token`, который нужно получить на странице [Personal Access Tokens](https://github.com/settings/tokens)):
	* `git clone https://github.com/{{ username }}/de-project-1.git`
3. Перейдите в директорию с проектом: 
	* `cd de-project-1`
4. Выполните проект и сохраните получившийся код в локальном репозитории:
	* `git add .`
	* `git commit -m 'my best commit'`
5. Обновите репозиторий в вашем GutHub-аккаунте:
	* `git push origin main`

### Как запустить контейнер
Запустите локально команду:

```
docker run -d --rm -p 3030:3030 -p 3000:3000 --name=de-project-sprint-1-server-local sindb/project-sprint-1:latest
```

После того как запустится контейнер, у вас будут доступны:
1. VS Code
2. CloudBeaver
3. PostgreSQL (запросы лучше выполнять через CloudBeaver)
