## getting-start

### Base on

1. `sass` 嵌套式 和 缩进式 书写规则
2. 模块化开发(编译时为每个模块添加文件名的 class, 所以需要保证每个模块是封闭的［是不是用参数控制，是否添加外层 class］)
3. 使用`sass`的书写规则，在此基础上添加了一些新的语法。


### 语法 

1. `!` 不编译为 html 标签

#### scss -> hcss

```
!html {
  font-size: 10px;
}

!* {
  margin: 0 padding: 0
}
```

#### sass -> hass

```
!html
  font-size: 10px
!*
  margin: 0
  padding: 0

```


2. html 标签内文字（`&text`）和属性（`&attr`）

#### scss -> hcss

```
//header.hcss

header.header#header
  width: 100%
  height: 6rem
  font-size: 1.6rem

  a.log
    text-decoration: none

    &text: "hcss 规则"
    &attr: "href=www.baidu.com", "attr=链接"

    img
      &attr: "src=#"

```

#### sass -> hass

```
//header.hcss

header.header#header {
  width: 100%;
  height: 6rem;
  font-size: 1.6rem;
  a.log {
    text-decoration: none;
    &text: "hcss 规则";
    &attr: "href=www.baidu.com", "attr=链接";
    img {
      &attr: "src=#";
    }
  }
}
```


3. 模块化： 公共布局（`&extends`）, 模块（ `&block`) 和 引入模块（`&include`）

#### &block

```
// layout.hass

html
  head
    &block head
    link
      &attr: "href=#"
  body
    &block body

!html
  font-size: 10px

!*
  margin: 0
  padding: 0

```

```
// header.hass
header.header#header
  width: 100%
  height: 6rem
  font-size: 1.6rem

  a.log
    text-decoration: none

    &text: "hcss 规则"
    &attr: "href=www.baidu.com", "attr=链接"

    img
      &attr: "src=#"

```

#### &extends 和 &include

```
// index.hass
&extends layout

&block body
&include header
```

