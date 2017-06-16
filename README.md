<h1>calc.asm</h1>
<h3>Minimal arithmetic calculator in x86 assembly.</h3>

![img](https://raw.githubusercontent.com/flouthoc/calc.asm/master/art/calc.gif)

<hr>
This a simple arithmetic calculator written in x86 assembly with minimalistic operation support like `Addition` , `Subtraction` , `Multiplication` and `Division`.I have tried to kept <strong>source highly documented</strong> by commenting on each line so that beginners can easily understand the source.If you feel that these comments source or anything can be improved create a <strong>pull-request</strong> now. If you found it useful <strong> Star it </strong> or <strong>follow me on github </strong>


<h4>Usage</h4>
`./calc <operator> <operand1> <operand2>`


<h4>Operations Supported</h4>
`"+"` For Addition <br>
`"-"` For Subtraction <br>
`"*"` For Multiplication <br>
`"/"` For Division <br>


<h4>Compiling</h4>
```bash
nasm -f elf64 -o calc.o calc.asm
ld -d calc calc.o
```
or

```bash
make
```
<h4>Blogs which helped me</h4>
http://0xax.blogspot.in/search/label/asm

<h1> Fork it</h1>
Twitter @flouthoc<br>
Email flouthoc@gmail.com

