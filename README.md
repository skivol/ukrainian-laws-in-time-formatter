# Утиліти для створення PDF документів з текстами нормативно-правових документів та їх змінами у часі
А також деякі створені за їх допомогою документи.

# Переваги перед веб версією
* використання шрифта без засічок (зручніше читати на екрані);
* можливість форматування в дві колонки (для полегшення читання документів);
* краще відображення змін в тексті;
* можливість вивчати документ без подальшого (після завантаження файла) доступу до мережі.

# Переваги веб версії
* остання (більша вірогідність) версія документа;
* краще ручне форматування / наявність всіх зображень (не всі з них присутні в тексті, що надається через програмний інтерфейс).

# Збережені функції в PDF версії документа
* зовнішні/внутрішні посилання;
* таблиці;
* зміст;
* базове форматування тексту.

# Репозиторії
* [skivol/ukrainian-laws-in-time](https://github.com/skivol/ukrainian-laws-in-time) - для відображення змін в документах за допомогою Git, а також для доступу до тексту останньої версії.

# Інструменти
* `git diff` в `html` -> [diff2html](https://diff2html.xyz/);
* Chrome Headless (конвертація html в pdf);
* `doc` в `pdf` -> libreoffice
* [pandoc](https://pandoc.org/) + XeLaTeX (перетворення з markdown в pdf, та поєднання з іншими pdf документами);
* `sed` скрипти для додання деякого форматування до документів на льоту.

# Ліцензія
[![Ліцензія Creative Commons](https://i.creativecommons.org/l/by/4.0/88x31.png)](http://creativecommons.org/licenses/by/4.0/)  
Цей твір ліцензовано на умовах [Ліцензії Creative Commons Зазначення Авторства 4.0 Міжнародна](http://creativecommons.org/licenses/by/4.0/).

