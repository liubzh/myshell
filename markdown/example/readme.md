# Markdown语法帮助文档

## 一、标题
在文字写书写不同数量的#可以完成不同的标题，如下：

# 一级标题
## 二级标题
### 三级标题
#### 四级标题
##### 五级标题
###### 六级标题
等号及减号也可以进行标题的书写，不过只能书写二级标题，并且需要写在文字的下面，减号及等号的数量不会影响标题的基数，如下：

二级标题
=========

二级标题
---------


## 二、列表
无序列表的使用，在符号“-”后加空格使用。如下：

- 无序列表1
- 无序列表2
- 无序列表3
如果要控制列表的层级，则需要在符号“-”前使用空格。如下：

- 无序列表1
- 无序列表2
  - 无序列表2.1
     - 列表内容
     - 列表内容

 
有序列表的使用，在数字及符号“.”后加空格几个，如下：

1. 有序列表1
2. 有序列表2
3. 有序列表3

有序列表如果要区分层级，也可以在数字前加空格，如下：

1. 有序列表1
2. 有序列表2
 1. 有序列表1.1
 2. 有序列表1.2
 3. 有序列表1.3
3. 有序列表3


## 三、引用
引用的格式是使用符号“>”后面书写文字，及可以使用引用。如下：

以下是引用示例：
>这个是引用
> 是不是和电子邮件中的
> 引用格式很像

以下是多重引用示例：
> 多层引用
> - 一重
>> 多层引用
>> - 二重
>>> 多层引用
>>> - 三重

## 四、粗体与斜体
粗体的使用是在需要加粗的文字前后各加两个“*”，而斜体的使用则是在需要斜体的文字前后各加一个“*”，如果要使用粗体和斜体，那么就是在需要操作的文字前后各加三个“*”。如下：

**这个是粗体**
*这个是斜体*
***这个是粗体加斜体***


## 五、链接与图片
在文中直接加链接，中括号中是需要添加链接的文字，圆括号中是需要添加的链接，如下：

[link text](http://example.com/ "optional title")
在引用中加链接，第一个中括号添加需要添加的文字，第二个中括号中是引用链接的id，之后在引用中，使用id加链接：如下：

[link text][id]
[id]: http://example.com/ "optional title here"
在文中直接引用链接，直接使用尖括号，把链接加入到尖括号中就可以实现，如下：

<http://example.com/> or <address@example.com>
插入互联网上图片，格式如下：

![这里写图片描述](icon.png)
![这里写图片描述][test-icon]
[test-icon]: icon.png


## 六、代码块
用TAB键起始的段落，会被认为是代码块，如下：

    <php>
        echo “hello world";
    </php>
如果在一个行内需要引用代码，只要用反引号`引起来就好，如下：

Use the `printf()` function.


## 七、分割线
可以在一行中用三个以上的星号、减号、底线来建立一个分隔线，同时需要在分隔线的上面空一行。如下：

---
****
___


## 八、代码高亮
在需要高亮的代码块的前一行及后一行使用三个反引号“`”，同时第一行反引号后面表面代码块所使用的语言，如下：

以下是一段 ruby 代码块：
```ruby
require 'redcarpet'
markdown = Redcarpet.new("Hello World!")
puts markdown.to_html
```

以下是一段 bash 代码块：
```bash
local mds=$(find . -name *.md)
local count=$(echo ${mds} | wc -w)
if [ ${count} -eq 1 ]; then
    FILE_IN=${mds}
    echo "检索到 md 文档： ${mds}"
else
    printUsage
    exit 1
fi
```

以下是一段 java 代码块：
```java
public class CodeBlock{
    public static void main(String[] args){
        System.out.println("Test java code block");
    }
}
```


## 九、表格
可以使用冒号来定义表格的对齐方式，如下：

| Tables | Are | Cool |
| ------------- |:-------------:| -----:|
| col 3 is | right-aligned | $1600 |
| col 2 is | centered | $12 |
| zebra stripes | are neat | $1 |

## 十、绘制UML图
可以渲染时序图：

```sequence
Alice->Bob: Hello Bob, how are you?
Note right of Bob: Bob thinks
Bob-->Alice: I am good thanks!
```
或者流程图：

```flow
st=>start: Start|past:>http://www.google.com[blank]
e=>end: End:>http://www.google.com
op1=>operation: My Operation|past
op2=>operation: Stuff|current
sub1=>subroutine: My Subroutine|invalid
cond=>condition: Yes
or No?|approved:>http://www.google.com
c2=>condition: Good idea|rejected
io=>inputoutput: catch something...|request

st->op1(right)->cond
cond(yes, right)->c2
cond(no)->sub1(left)->op1
c2(yes)->io->e
c2(no)->op2->e
```
