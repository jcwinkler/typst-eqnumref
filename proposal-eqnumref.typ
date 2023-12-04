#set text(font: "New Computer Modern", size: 12pt)

// Format section titles
#set heading(numbering: "1.1")
//#show heading: set block(above: 2em, below: 1em)

// Adjust paragraphs
#set par(justify: true)
#show par: set block(spacing: 1.0em)

// Numbered lists contain subsection number (heading level 2) in front of the enumeration
#set enum(tight: false, full: true, spacing: 1em, numbering: (..args) => {
  let vals = args.pos();
  let secnum = counter(heading).display((..it) => {
      let items = it.pos()
      return str(items.at(1))
    })
  if vals.len() == 1 {
    return secnum + "-" + str(vals.at(0));
  } else {
    return secnum + "-" + str(vals.at(0)) + str(("a", "b", "c", "d", "e", "f", "g", "h").at(vals.at(1) - 1));
  }
})
#show enum: set block(spacing: 1.5em)

// Adjust bullet lists
#set list(tight: false, spacing: 1em)
#show list: set block(spacing: 1.5em)

// Links in blue
#show link: set text(fill: blue)

// Some helpers
#let Covers = {
  text(weight: "bold", fill: green, "Covers:")
}
#let Proposal = {
  text(weight: "bold", fill: blue, "Proposal:")
}
#let Open = {
  text(weight: "bold", fill: red, "Open:")
}

// ======================================================================================

= Specification: Equation numbering and referencing <sec:req>
A consistent and highly flexible equation-numbering and -referencing system is a key for 
making typst a successful typesetting system in the scientific world (maybe replacing LaTeX...).
This document tries to summarize the requirements and proposes changes to the typst 
typesetting language to cover all aspects. Open topics are #text(fill: red, "colored red").

== Use cases
The following general use cases must be covered by an implementation:
  
  + Each equation in a document is automatically numbered (independently of the existence 
    of equation labels).

  + Each equation in a document is automatically numbered (independently of the existence 
    of equation labels), except for certain ones (specified by the user).
  
  + No equation in a document is numbered.
  
  + Only equations which have a label (and, hence, are referenced somewhere) are numbered.



== Basic numbering and referencing
+ There should be an option to include the current section number in the equation number, 
  as it is done in this draft, e.g. (1.1) instead of (1).

+ Set of aligned and partially numbered subequations
  // Since the stuff we propose here is not implemented yet, we format it manually in tables
  // A function doing this would be nice here, e.g. #eqref(content)
  #table(
  columns: (90%, 10%),
  align: (center, right),
  stroke: none,
  $#h(3.2em) a = b +c$, [],
  $#h(4.2em) = d + g$,  [(1.1a)],
  $z + y = x$,          [(1.1b)]
)

+ Set of aligned and partially numbered ordinary equations
  #table(
  columns: (90%, 10%),
  align: (center, right),
  stroke: none,
  $i = j$,               [(1.2)],
  $#h(1.4em) w = a + b$, [],
  $#h(0.8em) = c$,       [(1.3)]
  )

+ Referencing:
  + Reference to a single subequation: (1.1a)

  + Reference to whole subequation block: (1.1)
  
  + Reference to single ordinary equation: (1.2)
  
  + Reference to set of ordinary equations: (1.2), (1.3)
  
  + Referencing in equation itself:
    #table(
    columns: (90%, 10%),
    align: (center, right),
    stroke: none,
    $z = a =^#[(1.1a)] d + g$,               [(1.4)]
    )


== Advanced subequations
+ Subequations distributed over multiple paragraphs:
    #table(
    columns: (90%, 10%),
    align: (center, right),
    stroke: none,
    $a = b$,                 [(1.5a)]
    )
  Another subequation after some text
    #table(
    columns: (90%, 10%),
    align: (center, right),
    stroke: none,
    $d + c = e + f + x + z$,  [(1.5b)]
    )
  Normal numbering continues:
    #table(
    columns: (90%, 10%),
    align: (center, right),
    stroke: none,
    $e = f$,                   [(1.6)]
    )


+ It should be possible to align subequations if text is written between them:
    #table(
      columns: (90%, 10%),
      align: (center, right),
      stroke: none,
      $a = b$,                 [(1.7a)]
    )
  Another subequation after some text
    #table(
      columns: (90%, 10%),
      align: (center, right),
      stroke: none,
      $#h(3.5em) d + c = e + f + x + z$,  [(1.7b)]
    )


== Advanced equation typesetting    
+ It should be possible to set one number per equation system only 
  (align + split in LaTeX + AmsMath):
  #table(
    columns: (90%, 10%),
    align: (center, horizon + right),
    stroke: none,
    $
      A &= B + C \
      D + E &= F + G
    $,  [(1.8)]
  )

+ It should be possible to enable multi-line equations wich are nicely 
  typesetted (multline in LaTeX  + AmsMath):
  #table(
    columns: (90%, 10%),
    align: (center, horizon + right),
    stroke: none,
    $
      a + b + c + d + e + f + g + h + i + j = \
      #h(10em) k + l + m + n + o + p + q + r + s + t + u
    $,  [(1.9)]
  )

+ It should be possible to place equation numbers to the left:
  #table(
    columns: (10%, 90%),
    align: (left, center),
    stroke: none,
    [(1.10)], $a = b$
  )


#set enum(tight: false, full: true, spacing: 1em, numbering: "1.1.")

= Realization in typst
Based on the pull-request #link("https://github.com/typst/typst/pull/1849", "on Github") 
and the associated discussion as well as the discussion 
#link("https://discord.com/channels/1054443721975922748/1176478327473709108", "on Discord")
the following is proposed:

+ *Change of the equation function*
  + `numbering`-keyword: Possibility to include Section or other numbers. 
    Example: `numbering: "({h1}.1a)"` -> section number is included in the 
    equation number. #Covers 2-1.

    #Open Define consistent syntax. In principal, it should be possible 
    to include numbers of any type of labels 

    #Open What is the implication of `numbering = "(1)"` regarding subequations 
    (see below). `"(1a)"`? (Preferred in my opinion)

  + #Proposal New keyword `numbering-mode` with the following options:
    - `"by-equation"` (default): Each equation (i.e.\,a block included in `\$ \$`)
    automatically gets a number, independently of the existence of labels 
    (#Covers use-cases 1-1 and 1-2, can be tweaked by special label `<*>`, see below.).
    - `"by-line"`: In each equation each line is numbered, independently of the 
    existence of labels  (#Covers use-cases 1-1 and 1-2, can be tweaked by special 
    label `<*> `see below.)
    - `"by-label"`: Only equations and lines of equations are numbered that 
    have a label (#Covers use-case 1-4).
  
    If `numbering = none` this keyword is ignored (#Covers use-case 1.3).

  + #Proposal New keyword `numbering-align` with the following options:
    - `"right"` (default): Place number to the right of the equation (at right page margin).
    - `"left"`: Place number to the left of the equation (at left page margin).

    #Covers 4-3.

  + #Proposal New keyword `align-subequblocks` (Default: `false`): If true ensures 
  that subequations distributed over consecutive blocks are aligned (\LaTeX: 
  subequations + align + intertext).  #Covers 3-2.
  

+ *Enhanced functionality of labels (if `numbering` is not `none`)*
  + #Proposal Special Label `<*>`: Do not put an equation number here
  (only useful if `numbering-mode="by-label"` or \\ `numbering-mode="by-equation"`, 
  so you can exclude very specific equations or lines from being numbered).
    + Labels can be placed in each line of an equation and/or behind an equation block:
      ```typst
      $
      a     & = b + c  \
            & = d +g   <eq:a>
      z + y & = x.     <eq:z>
      $ <eq:az>    
      ```
  + Labels placed in lines of equations also act as a line separator, so no 
    additional `\` is needed.

    If `numbering-mode="by-label"` the placement of labels determines the kind of numbering:
    
      -  Labels only in lines: Normal equation as (1), (2), \ldots. (#Covers 2-3, 2-4c, 2-4d)
      -  Labels only after equation block: Whole equation block gets one number (#Covers 4-1)
      -  Labels in lines as well as behind the equation block: Lines are numbered as 
         subequations, the whole block can be referenced by its main number 
         (#Covers 2-2, 2-4a, 2-4b)
      -  Lines/ equations without a label are not numbered.
      -  The same label behind two consecutive equation blocks renders the lines of 
         these blocks as subequations. It is an error if two non consecutive 
         equation blocks have the same label. #Covers 3-1.
    
+ Referencing within an equation should be possible (#Covers 2-4e):
  ```typst
  $
    z = a =^#[@eq1:a] d + g 
  $    
  ```


#text(fill: red, weight: "bold", "Things that are still open and need to be fixed:")
- If `numbering-mode="by-line"` it is not possible to mark an equation block as a 
  subequation block without explicitly defining a label for them. This is not nice
  in the case you do not reference the equations and, hence, do not want to define
  labels (use-case 1-1). 

  #Proposal Define another special label marking the block as an ("unlabled")
  subequations block (e.g. `<\#>`?).
  


#text(fill: green, weight: "bold", "Things that are already covered by the current implementation:")

- Nicely typesetted multi-line equations (4-2):
  ```typst
$
a + b + c + d + e + f + g + h + i + j =
#h(5em) k + l + m + n + o + p + q + r + s + t + u <eq6>
$
  ```


= With this proposal the output of @sec:req can be generated as follows:

```typst
#set math.equation(numbering: "({h1}.1a)", numbering-mode: "by-label", supplement: none)

= Equation numbering and referencing
Set of aligned and partially numbered subequations
$
    a     & = b + c  \
          & = d +g   <eq1:a>
    z + y & = x.     <eq1:z>
$ <eq1>

Set of aligned and partially numbered ordinary equations
$
  i & = j       <eq2:i>
  w & = a + b   \
    & = c       <eq2:c>
$

Referencing:
  - Reference to a single subequation: @eq1:a
  - Reference to whole subequation block: @eq1
  - Reference to single ordinary equation: @eq2:i
  - Reference to set of ordinary equations: @eq2:i, @eq2:c
  - Referencing in equation itself:
    $ 
      z = a =^#[@eq1:a] d + g 
    $ <zadg>

= Advanced subequations
Subequations distributed over multiple paragraphs:
$ 
  a = b   <eq3:ab> 
$ <eq3>

Another subequation after some text
$ 
  d + c = e + f + x + z   <eq3:cd> 
$ <eq3> 

Normal numbering continues:
$ 
  e = f  
$ <eq4:ef>


It should be possible to align subequations if text is written between them:

#set math.equation(numbering: "({h1}.1a)", numbering-mode: "by-label", align-subeqblocks=true, supplement: none)
$ 
  a = b + c   <eq3:ab> 
$ <eq3>

Another subequation after some text
$ 
  d + c &= e + f + x + z   <eq3:cd> 
$ <eq3> 

= Advanced equation typesetting
It should be possible to set one number per equation system
only (align + split in LATEX + AmsMath):

$
      A &= B + C
  D + E &= F + G
$ <eq5>

$
  a + b + c + d + e + f + g + h + i + j =
  #h(5em) k + l + m + n + o + p + q + r + s + t + u <eq6>
$

It should be possible to place equation numbers to the left:
#[
  #set math.equation(numbering-align: "left")
  $ a = b $ <eq7>
]  
```


== The same with numbering-mode="by-line"

Only what is referenced has a label, but all equations are numbered except for specific ones.
```typst
#set math.equation(numbering: "({h1}.1a)", numbering-mode: "by-line", supplement: none)

= Equation numbering and referencing
Set of aligned and partially numbered subequations
$
    a     & = b + c  <*>
          & = d +g   <eq1:a>
    z + y & = x.     <eq1:z>
$ <eq1>

Set of aligned and partially numbered ordinary equations
$
  i & = j       <eq2:i>
  w & = a + b   <*>
    & = c       <eq2:c>
$

Referencing:
  - Reference to a single subequation: @eq1:a
  - Reference to whole subequation block: @eq1
  - Reference to single ordinary equation: @eq2:i
  - Reference to set of ordinary equations: @eq2:i, @eq2:c
  - Referencing in equation itself:
    $ 
      z = a =^#[@eq1:a] d + g 
    $

= Advanced subequations
Subequations distributed over multiple paragraphs:
$ 
  a = b
$ <#>

Another subequation after some text
$ 
  c = d 
$ <#> 

Normal numbering continues:
$ 
  e = f  
$
```