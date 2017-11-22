# Dupplot

Visualizing duplications and copypastes graphically via plots of line
matches

This is the example after running dupplot against t/file-a.txt and t/file-b.txt
![dup-plot.png](dup-plot.png)


- Here is the comparison of dupplot_old.pl against itself
![dupplot-on-dupplot.png](dupplot-on-dupplot.png)

- And after seeing about the duplication, I decided to refactor
it. It's the current dupplot.pl
![dupplot-on-dupplot-refactored.png](dupplot-on-dupplot-refactored.png)


Way better, no?


More examples:

Being the file a:

    1
    1
    1
    1
    1

And the file b:

    2
    1
    3
    4
    1
    5


This are some combinations:

- a vs a:

![a_vs_a.png](a_vs_a.png)

- a vs b:

![a_vs_b.png](a_vs_b.png)


- b vs b:

![b_vs_b.png](b_vs_b.png)
