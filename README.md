# My Z80 Assembler

(That's not a name, I just can't think of anything to call this)

Some small things to note:

* Not all instructions are implemented
* I haven't verified that most instructions are actually generated correctly
* This is just for fun

## Some big-ish things to note

This assembler does not depend on whitespace for parsing, which means you can write any number of instructions/labels/directives on a single line.
However, this has the downside of requiring an extra comma before the first operand of any instruction which takes operands.

For example,
```
ld a, 0
```
would need to be written as
```
ld, a, 0
```

---

This assembler supports binary, hex, and decimal literals. Binary and hex need the `0b` and `0x` prefixes.

The syntax `'a'` can also be used to write the ASCII code of any character as a single byte.

---

Single line comments can be written with `;`, and multiline comments can be opened with `/*`, and closed with `*/`.

Labels are written as `Name:`, where `Name` needs to be unique (aka not already defined as a label elsewhere).

---

This assembler uses `!` as a prefix for directives, and only supports three directives (for now):

| Directive name/parameters | Usage |
|---------------------------|-------|
| `!org Short` | Seeks to address `Short` inside of the assembler's virtual Z80 address space. This means that any instructions/data following this directive will expect to be loaded at the address given. |
| `!db Byte` | Will write `Byte`'s value as a raw byte to the next position in the assembler's virtual Z80 memory. |
| `!dw Short` | Same as `!db`, but with a 16 bit value instead of an 8 bit one. |

Both `db` and `dw` allow multiple values to be written as long as they are separated by commas, for example:

```
!dw 1, 2, 3, 4
```
would be result in
```
00 01 00 02 00 03 00 04
```

For `db`, `Byte` can also be `"string"`, which is equal to `db 's', 't', 'r', 'i', 'n', 'g'`.

For `dw`, `Short` can also be `LabelName`, where `LabelName` is the name of a label somewhere in the program. This will result in the 16 bit address of `LabelName` being written.

Here's some more examples:

```
; A null terminated string

!db "Hello world!', 0
```

```
; A jump table

!dw FunctionOne, FunctionTwo, FunctionThree
```

```
; A variable

!dw 0
```

---

The assembler should be invoked as `Z80.exe InputFile OutputFile` on Windows, and `./Z80.elf InputFile OutputFile` on Linux.

`InputFile` should be the path to an input file containing instructions, labels, and directives, and `OutputFile` should be a path to a file which will have the encoded instructions written to it.

---

Some registers have slightly different names. The big one is that `(hl)` when used in place of `a`/`b` (or any 8 bit register) should be written as `(hlb)`. This is because `(hl)` in a majority of contexts means `the 16 bits in memory at the address inside of hl`, and not `the 8 bits in...`.

I'm not sure how other assemblers solve this problem, but due to the way I wrote this assembler, I would have to allow `ld, a, (bc)`/`ld, a, (de)`/`ld, a, (sp)` in order to allow `ld, a, (hl)`. 3 of which are invalid, and I consider one non-standard name better than allowing 3 different ways to generate invalid instructions.

Additionally, some of the "undocumented" instructions involving `ixl`/`ixh`/`iyl`/`iyh` are implemented, so those registers are also valid.

## Example code:

Increment a variable endlessly:

```
ld, hl, Counter
ld, a, 0

Increment:
    inc, a
    ld, (hlb), a
    jp, Increment

Counter: !db 0
```

## Compiling the assembler

This is written in a language I also wrote, which can be found [here](https://github.com/CloakerSmoker/Relax-Language) (check the documentation in that repo to learn more).

* `make` will compile the assembler for the current platform, and output an executable for the current platform
* `make linux` will compile the assembler for Linux, and output an ELF file
* `make windows` will compile the assembler for Windows, and output a PE/`exe` file
* `make all` will compile the assembler for both Linux and Windows

The backbone of the assembler is `Z80.txt`, which is a text representation of the Z80 instruction set. This file is organized in columns, with the format:

```
InstructionName     Opcode      OperandType1,OperandType2       Flags1|FlagN
```

When any one instruction is encountered inside of input code, it is matched against all definitions of a single instruction name, checking if the types of the written instruction's operands match any "template" instructions (as defined in `Z80.txt`). When a matching instruction is found, that instruction is emitted using `Opcode`/`Flags` to decide how to actually encode the instruction.