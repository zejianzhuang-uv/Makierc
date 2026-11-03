# Makierc

English | [中文](README.zh-CN.md)

A ready-made plot style for [Makie](https://docs.makie.org). Call one function and your figures
get inward ticks on all four sides, dashed grid lines, a serif font and a clean legend. You can
change any part of the style with a keyword.

## Installation

```julia
using Pkg
Pkg.add(url = "https://github.com/zejianzhuang-uv/Makierc.git")
Pkg.add("CairoMakie")
```

Makierc sets the style only. You also need a Makie backend, such as CairoMakie, to draw and save
figures.

## Tutorial

### 1. Make your first figure

Load the packages and call `load_makie_config!()` once, before you create any figures:

```julia
using CairoMakie, Makierc

load_makie_config!()

x = 0:0.1:2π
fig = Figure()
ax = Axis(fig[1, 1]; xlabel = "x", ylabel = "y", title = "My first figure")
lines!(ax, x, sin.(x); label = "sin(x)")
lines!(ax, x, cos.(x); label = "cos(x)")
axislegend(ax)
fig
```

### 2. Save the figure

Use `savefig` to save it. The file format comes from the file name:

```julia
savefig("first_figure.pdf", fig)
```

The background is transparent by default, which suits slides and web pages. To keep the
background, use `transparent = false`. Other keywords go to Makie's `save`:

```julia
savefig("first_figure.png", fig; transparent = false, px_per_unit = 3)
```

### 3. Change the style

Pass the settings you want to change. Everything else keeps its default value:

```julia
load_makie_config!(lw = 2.5, fontsize = 18, markersize = 10)
```

The new style applies to figures you create after this call, so create the figure again:

```julia
fig = Figure()
ax = Axis(fig[1, 1]; xlabel = "x", ylabel = "y")
lines!(ax, x, sin.(x); label = "sin(x)")
scatter!(ax, 0:6, sin.(0:6); label = "samples")
axislegend(ax)
savefig("custom_style.pdf", fig)
```

Each call starts again from the defaults. Here the second call resets `lw`, so the line width is
back to 1.8:

```julia
load_makie_config!(lw = 2.5)
load_makie_config!(fontsize = 18)
```

To draw figures without grid lines, use `grid = false`:

```julia
load_makie_config!(grid = false)
```

A misspelled keyword raises a `MethodError`, so a typo cannot silently do nothing.

### 4. Use the optional colours and padding

Makie's default colours and figure padding are used unless you ask for others. Makierc includes
a 16-colour palette:

```julia
load_makie_config!(palette = Makierc.MPL_PALETTE, figure_padding = 15)
```

You can also pass your own palette:

```julia
load_makie_config!(palette = (color = [:black, :red, :blue], patchcolor = [:gray, :pink, :lightblue]))
```

### 5. Choose a font

The default font is Times New Roman. **It must be installed on your computer**: if it is missing,
Makie picks another font without stopping. To use a different font:

```julia
load_makie_config!(font_regular = "CMU Serif")
```

This sets the regular font only. Text that Makie draws in bold, such as a legend title, still
uses Makie's own bold font.

### 6. Write math with LaTeX

Put an `L` in front of a string to write it as LaTeX. You do not need to install LaTeX:

```julia
using CairoMakie, Makierc

load_makie_config!()

x = range(0, 2π, 200)
fig = Figure()
ax = Axis(fig[1, 1];
    xlabel = L"\sqrt{s}\;[\mathrm{MeV}]",
    ylabel = L"|T(s)|^2",
    title = "A figure with math",
)
lines!(ax, x, sin.(x) .^ 2; label = L"\alpha\,\sin^2\theta")
lines!(ax, x, cos.(x) .^ 2; label = L"\beta\,\cos^2\theta")
axislegend(ax)
fig
```

A figure uses two fonts, and each one has its own keyword:

| Text | Example | Keyword | Default |
|---|---|---|---|
| Normal text and tick labels | `"A figure with math"` | `font_regular` | `"Times New Roman"` |
| LaTeX text | `L"\alpha\,\sin^2\theta"` | `font_latex` | `"STIX"` |

The default, `"STIX"`, looks like matplotlib's `mathtext.fontset: stix`. Its font files come with
Makierc, so you do not need to install them. To use a different font for LaTeX text, pass its name:

```julia
load_makie_config!(font_latex = "NewComputerModern")
```

The names you can use are `"STIX"`, `"NewComputerModern"` (Makie's default), `"TeXGyrePagella"`,
`"TeXGyreHeros"` and `"LucioleMath"`. Call `load_makie_config!` before you create the figure.

To use your own font files, pass a `FontFamily` with their full paths. Any style you leave out
comes from NewComputerModern:

```julia
family = Makie.MathTeXEngine.FontFamily(Dict(
    :regular => "/path/to/MyFont-Regular.otf",
    :italic => "/path/to/MyFont-Italic.otf",
    :bold => "/path/to/MyFont-Bold.otf",
    :bolditalic => "/path/to/MyFont-BoldItalic.otf",
    :math => "/path/to/MyFontMath.otf",
))
load_makie_config!(font_latex = family)
```

The fonts match matplotlib, but the layout comes from Makie, so a figure is not identical. For
example, `\frac` is larger than in matplotlib. In `\sum_{n=0}^{\infty} \int_0^1`, the lower limit of
the integral sits too close to the limit of the sum. To see the two side by side, open
[`test/latex_font.ipynb`](test/latex_font.ipynb).

### 7. Go back to Makie's default style

```julia
set_theme!()
Makie.MathTeXEngine.set_texfont_family!()  # LaTeX font: set_theme! does not reset it
```

## All settings

These are the keywords of `load_makie_config!`. You can also read this list in the Julia REPL
with `?load_makie_config!`.

| Group | Keyword | Default |
|---|---|---|
| Lines | `lw` (for `Lines`, `Errorbars` and `VLines`) | `1.8` |
| Font | `fontsize` | `16` |
| | `font_regular` | `"Times New Roman"` |
| | `font_latex` | `"STIX"` |
| Markers | `markersize` | `15` |
| Grid | `grid` (`false` turns off every grid) | `true` |
| | `xgridstyle`, `ygridstyle` | `Linestyle([0, 3.7, 5.3])` |
| | `xgridcolor`, `ygridcolor` | `"#b0b0b0"` |
| | `xgridwidth`, `ygridwidth` | `0.8` |
| Tick count | `k_ideal`, `k_min`, `k_max` | `5`, `4`, `10` |
| Ticks | `xtickalign`, `ytickalign` | `1` |
| | `xminortickalign`, `yminortickalign` | `1` |
| | `xticksmirrored`, `yticksmirrored` | `true` |
| | `xminorticksvisible`, `yminorticksvisible` | `true` |
| | `xminorticks`, `yminorticks` | `IntervalsBetween(5)` |
| Legend | `legend_backgroundcolor` | `(:white, 0.6)` |
| | `legend_framecolor` | `(:black, 0.3)` |
| | `legend_framewidth` | `1.5` |
| Figure | `figure_padding` | `nothing` (Makie's default) |
| | `palette` | `nothing` (Makie's default) |

The tick count settings apply to both axes. `k_ideal` is the number of ticks to aim for, and
`k_min` and `k_max` are its limits.

## Running the tests

```julia
using Pkg
Pkg.test("Makierc")
```
