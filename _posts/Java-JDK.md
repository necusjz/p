---
title: Java JDK
date: 2021-03-24 15:45:41
tags:
  - OpenSource
---
## 工厂模式在 Calendar 类中的应用
Calendar 类提供了大量跟日期相关的功能代码，同时，又提供了一个 getInstance() 工厂方法，用来根据不同的 TimeZone 和 Locale 创建不同的 Calendar 子类对象。也就是说，功能代码和工厂方法代码耦合在了一个类中。所以，即便我们去查看它的源码，如果不细心的话，也很难发现它用到了工厂模式。同时，因为它不单单是一个工厂类，所以，它并没有以 Factory 作为后缀来命名。从代码中，我们可以看出，getInstance() 方法可以根据不同 TimeZone 和 Locale，创建不同的 Calendar 子类对象，比如 BuddhistCalendar、JapaneseImperialCalendar、GregorianCalendar，这些**细节完全封装在工厂方法中，使用者只需要传递当前的时区和地址**，就能够获得一个 Calendar 类对象来使用，而获得的对象具体是哪个 Calendar 子类的对象，使用者在使用的时候并不关心：
```java
public abstract class Calendar implements Serializable, Cloneable, Comparable<Calendar> {
    //...
    public static Calendar getInstance(TimeZone zone, Locale aLocale) {
        return createCalendar(zone, aLocale);
    }

    private static Calendar createCalendar(TimeZone zone,Locale aLocale) {
        CalendarProvider provider = LocaleProviderAdapter.getAdapter(CalendarProvider.class, aLocale).getCalendarProvider();
        if (provider != null) {
            try {
                return provider.getInstance(zone, aLocale);
            } catch (IllegalArgumentException iae) {
                // fall back to the default instantiation
            }
        }

        Calendar cal = null;
        if (aLocale.hasExtensions()) {
            String caltype = aLocale.getUnicodeLocaleType("ca");
            if (caltype != null) {
                switch (caltype) {
                    case "buddhist":
                        cal = new BuddhistCalendar(zone, aLocale);
                        break;
                    case "japanese":
                        cal = new JapaneseImperialCalendar(zone, aLocale);
                        break;
                    case "gregory":
                        cal = new GregorianCalendar(zone, aLocale);
                        break;
                }
            }
        }
        if (cal == null) {
            if (aLocale.getLanguage() == "th" && aLocale.getCountry() == "TH") {
                cal = new BuddhistCalendar(zone, aLocale);
            } else if (aLocale.getVariant() == "JP" && aLocale.getLanguage() == "ja" && aLocale.getCountry() == "JP") {
                cal = new JapaneseImperialCalendar(zone, aLocale);
            } else {
                cal = new GregorianCalendar(zone, aLocale);
            }
        }
        return cal;
    }
    //...
}
```

## 建造者模式在 Calendar 类中的应用
我们知道，建造者模式有两种实现方法，一种是单独定义一个 Builder 类，另一种是**将 Builder 实现为原始类的内部类**。Calendar 就采用了第二种实现思路：
```java
public abstract class Calendar implements Serializable, Cloneable, Comparable<Calendar> {
    //...
    public static class Builder {
        private static final int NFIELDS = FIELD_COUNT + 1;
        private static final int WEEK_YEAR = FIELD_COUNT;
        private long instant;
        private int[] fields;
        private int nextStamp;
        private int maxFieldIndex;
        private String type;
        private TimeZone zone;
        private boolean lenient = true;
        private Locale locale;
        private int firstDayOfWeek, minimalDaysInFirstWeek;

        public Builder() {}
        
        public Builder setInstant(long instant) {
            if (fields != null) {
                throw new IllegalStateException();
            }
            this.instant = instant;
            nextStamp = COMPUTED;
            return this;
        }
        // 省略 n 多 set() 方法
        public Calendar build() {
            if (locale == null) {
                locale = Locale.getDefault();
            }
            if (zone == null) {
                zone = TimeZone.getDefault();
            }
            Calendar cal;
            if (type == null) {
                type = locale.getUnicodeLocaleType("ca");
            }
            if (type == null) {
                if (locale.getCountry() == "TH" && locale.getLanguage() == "th") {
                    type = "buddhist";
                } else {
                    type = "gregory";
                }
            }
            switch (type) {
                case "gregory":
                cal = new GregorianCalendar(zone, locale, true);
                break;
                case "iso8601":
                GregorianCalendar gcal = new GregorianCalendar(zone, locale, true);
                // make gcal a proleptic Gregorian
                gcal.setGregorianChange(new Date(Long.MIN_VALUE));
                // and week definition to be compatible with ISO 8601
                setWeekDefinition(MONDAY, 4);
                cal = gcal;
                break;
                case "buddhist":
                cal = new BuddhistCalendar(zone, locale);
                cal.clear();
                break;
                case "japanese":
                cal = new JapaneseImperialCalendar(zone, locale, true);
                break;
                default:
                throw new IllegalArgumentException("unknown calendar type: " + type);
            }
            cal.setLenient(lenient);
            if (firstDayOfWeek != 0) {
                cal.setFirstDayOfWeek(firstDayOfWeek);
                cal.setMinimalDaysInFirstWeek(minimalDaysInFirstWeek);
            }
            if (isInstantSet()) {
                cal.setTimeInMillis(instant);
                cal.complete();
                return cal;
            }

            if (fields != null) {
                boolean weekDate = isSet(WEEK_YEAR) && fields[WEEK_YEAR] > fields[YEAR];
                if (weekDate && !cal.isWeekDateSupported()) {
                    throw new IllegalArgumentException("week date is unsupported by " + type);
                }
                for (int stamp = MINIMUM_USER_STAMP; stamp < nextStamp; stamp++) {
                    for (int index = 0; index <= maxFieldIndex; index++) {
                        if (fields[index] == stamp) {
                            cal.set(index, fields[NFIELDS + index]);
                            break;
                        }
                    }
                }

                if (weekDate) {
                    int weekOfYear = isSet(WEEK_OF_YEAR) ? fields[NFIELDS + WEEK_OF_YEAR] : 1;
                    int dayOfWeek = isSet(DAY_OF_WEEK) ? fields[NFIELDS + DAY_OF_WEEK] : cal.getFirstDayOfWeek();
                    cal.setWeekDate(fields[NFIELDS + WEEK_YEAR], weekOfYear, dayOfWeek);
                }
                cal.complete();
            }
            return cal;
        }
    }
}
```

工厂模式是用来创建不同但是相关类型的对象（继承同一父类或者接口的一组子类），由给定的参数来决定创建哪种类型的对象。建造者模式用来创建一种类型的复杂对象，**通过设置不同的可选参数，定制化地创建不同的对象**。网上有一个经典的例子很好地解释了两者的区别:
> 顾客走进一家餐馆点餐，我们利用工厂模式，根据用户不同的选择，来制作不同的食物，比如披萨、汉堡、沙拉。对于披萨来说，用户又有各种配料可以定制，比如奶酪、西红柿、起司，我们通过建造者模式根据用户选择的不同配料来制作不同的披萨。

粗看 Calendar 的 Builder 类的 build() 方法，你可能会觉得它有点像工厂模式。你的感觉没错，前面一半代码确实跟 getInstance() 工厂方法类似，根据不同的 type 创建了不同的 Calendar 子类。实际上，后面一半代码才属于标准的建造者模式，根据 setXXX() 方法设置的参数，来定制化刚刚创建的 Calendar 子类对象。

## 装饰器模式在 Collections 类中的应用

## 适配器模式在 Collections 类中的应用

## 
