﻿&НаСервереБезКонтекста
Функция ПолучитьСтавкуНДСНаСервере(НДССсылка) Экспорт
    // Проверяем, задана ли ставка
    Если НЕ ЗначениеЗаполнено(НДССсылка) Тогда
        Возврат 0;
    КонецЕсли;

    // Запросом получаем числовое значение ставки
    Запрос = Новый Запрос("ВЫБРАТЬ Первые 1 Ставка ИЗ Справочник.НДС ГДЕ Ссылка = &Ссылка");
    Запрос.УстановитьПараметр("Ссылка", НДССсылка);

    Результат = Запрос.Выполнить().Выбрать();

    Если Результат.Следующий() Тогда
        СтавкаЧисло = Результат.Ставка;
        // Защита от деления на 0
        Если СтавкаЧисло <> 0 Тогда
            Возврат СтавкаЧисло / 100;
        КонецЕсли;
    КонецЕсли;

    Возврат 0;
КонецФункции

&НаКлиенте
Процедура КонтрагентПриИзменении(Элемент)

    Если Не ЗначениеЗаполнено(Объект.Контрагент) Тогда
        Объект.Договор = Неопределено;
        Возврат;
    КонецЕсли;

    // Вызов серверной функции
    Договор = ПолучитьПоследнийДоговор(Объект.Контрагент);
    Объект.Договор = Договор;

КонецПроцедуры

&НаСервере
Функция ПолучитьПоследнийДоговор(Поставщик) Экспорт

    Если Не ЗначениеЗаполнено(Поставщик) Тогда
        Возврат Неопределено;
    КонецЕсли;

    Запрос = Новый Запрос;
    Запрос.Текст = 
        "ВЫБРАТЬ ПЕРВЫЕ 1
         |   Договоры.Ссылка
         |ИЗ
         |   Справочник.Договоры КАК Договоры
         |ГДЕ
         |   Договоры.Владелец = &Контрагент
         |УПОРЯДОЧИТЬ ПО
         |   Договоры.ДатаЗаключения УБЫВ";

    Запрос.УстановитьПараметр("Контрагент", Поставщик);
    Результат = Запрос.Выполнить().Выбрать();

    Если Результат.Следующий() Тогда
        Возврат Результат.Ссылка;
    Иначе
        Возврат Неопределено;
    КонецЕсли;

КонецФункции

&НаКлиенте
Процедура УслугиСуммаБезНДСПриИзменении(Элемент)  
    
    СтрокаТЧ = Элементы.Услуги.ТекущиеДанные;
    
    // Вызываем серверную функцию и получаем сумму НДС
    ПроцентНДС = ПолучитьСтавкуНДСНаСервере(СтрокаТЧ.Ставка);

    // Устанавливаем рассчитанное значение
    Если ПроцентНДС <> Неопределено Тогда
        СтрокаТЧ.СуммаНДС = ПроцентНДС * СтрокаТЧ.СуммаБезНДС;
    Иначе
        СтрокаТЧ.СуммаНДС = 0;
    КонецЕсли;
 
    СтрокаТЧ.Всего = СтрокаТЧ.СуммаБезНДС + СтрокаТЧ.СуммаНДС
КонецПроцедуры

&НаКлиенте
Процедура УслугиСуммаНДСПриИзменении(Элемент)
    УслугиСуммаБезНДСПриИзменении(Элемент);
КонецПроцедуры

&НаКлиенте
Процедура УслугиСтавкаПриИзменении(Элемент)     
    
    СтрокаТЧ = Элементы.Услуги.ТекущиеДанные;
    
    // Вызываем серверную функцию и получаем сумму НДС
    ПроцентНДС = ПолучитьСтавкуНДСНаСервере(СтрокаТЧ.Ставка);

    // Устанавливаем рассчитанное значение
    Если ПроцентНДС <> Неопределено Тогда
        СтрокаТЧ.СуммаНДС = ПроцентНДС * СтрокаТЧ.СуммаБезНДС;
    Иначе
        СтрокаТЧ.СуммаНДС = 0;
    КонецЕсли;

    // Перерасчёт
    УслугиСуммаНДСПриИзменении(Элемент);

КонецПроцедуры


&НаСервере
Функция ПолучитьСтавкуНДС_20()

    Возврат Справочники.НДС.НайтиПоНаименованию("20%");

КонецФункции

&НаКлиенте
Процедура УслугиПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
    СтрокаТЧ = Элементы.Услуги.ТекущиеДанные;

    Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Ставка) Тогда
        Ставка20 = ПолучитьСтавкуНДС_20();
        Если ЗначениеЗаполнено(Ставка20) Тогда
            СтрокаТЧ.Ставка = Ставка20;
        КонецЕсли;
    КонецЕсли;
КонецПроцедуры




