# Makierc

[English](README.md) | 中文

Makierc 为 [Makie](https://docs.makie.org/stable/) 提供一套现成的绘图样式。只需调用一个函数，图就会有四边朝内的刻度、虚线网格、衬线字体和简洁的图例。样式的任何部分都可以用关键字参数修改。

## 安装

```julia
using Pkg
Pkg.add(url = "https://github.com/zejianzhuang-uv/Makierc.git")
Pkg.add("CairoMakie")
```

Makierc 只负责设置样式。绘制和保存图形还需要一个 Makie 后端，例如 CairoMakie。

## 教程

### 1. 画第一张图

加载这些包，并在创建任何图形之前调用一次 `load_makie_config!()`：

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

### 2. 保存图形

用 `savefig` 保存图形，文件格式由文件名决定：

```julia
savefig("first_figure.pdf", fig)
```

背景默认是透明的，适合用于幻灯片和网页。如果要保留背景，请使用 `transparent = false`。其他关键字参数会传给 Makie 的 `save`：

```julia
savefig("first_figure.png", fig; transparent = false, px_per_unit = 3)
```

### 3. 修改样式

传入想修改的设置即可，其余设置保持默认值：

```julia
load_makie_config!(lw = 2.5, fontsize = 18, markersize = 10)
```

新样式只对这次调用之后创建的图形生效，所以需要重新创建图形：

```julia
fig = Figure()
ax = Axis(fig[1, 1]; xlabel = "x", ylabel = "y")
lines!(ax, x, sin.(x); label = "sin(x)")
scatter!(ax, 0:6, sin.(0:6); label = "samples")
axislegend(ax)
savefig("custom_style.pdf", fig)
```

每次调用都会从默认值重新开始。在下面的例子中，第二次调用会重置 `lw`，所以线宽回到 1.8：

```julia
load_makie_config!(lw = 2.5)
load_makie_config!(fontsize = 18)
```

要绘制没有网格线的图形，请使用 `grid = false`：

```julia
load_makie_config!(grid = false)
```

关键字拼写错误时会报 `MethodError`，所以拼写错误不会被悄悄忽略。

### 4. 使用可选的颜色和边距

除非另外指定，否则使用 Makie 默认的颜色和图形边距。Makierc 自带一套 16 色调色板：

```julia
load_makie_config!(palette = Makierc.MPL_PALETTE, figure_padding = 15)
```

也可以传入自己的调色板：

```julia
load_makie_config!(palette = (color = [:black, :red, :blue], patchcolor = [:gray, :pink, :lightblue]))
```

### 5. 选择字体

默认字体是 Times New Roman。**电脑上必须装有这个字体**：如果缺少这个字体，Makie 会改用另一种字体，并继续运行。要使用其他字体：

```julia
load_makie_config!(font_regular = "CMU Serif")
```

这里只设置常规字体。Makie 用粗体绘制的文字（例如图例标题）仍然使用 Makie 自带的粗体字体。

### 6. 用 LaTeX 写数学公式

在字符串前加 `L`，就可以按 LaTeX 书写。不需要安装 LaTeX：

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

一张图用到两种字体，分别由各自的关键字参数设置：

| 文字 | 示例 | 关键字 | 默认值 |
|---|---|---|---|
| 普通文字和刻度标签 | `"A figure with math"` | `font_regular` | `"Times New Roman"` |
| LaTeX 文字 | `L"\alpha\,\sin^2\theta"` | `font_latex` | `"STIX"` |

默认值 `"STIX"` 的效果接近 matplotlib 的 `mathtext.fontset: stix`。字体文件已包含在 Makierc 中，不需要另外安装。要给 LaTeX 文字换一种字体，传入字体名称即可：

```julia
load_makie_config!(font_latex = "NewComputerModern")
```

可用的名称有 `"STIX"`、`"NewComputerModern"`（Makie 的默认字体）、`"TeXGyrePagella"`、`"TeXGyreHeros"` 和 `"LucioleMath"`。请在创建图形之前调用 `load_makie_config!`。

要使用自己的字体文件，请传入一个带完整路径的 `FontFamily`。没有指定的字形样式会使用 NewComputerModern：

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

字体与 matplotlib 一致，但排版由 Makie 完成，所以图形不会完全相同。例如，`\frac` 比 matplotlib 中的大；在 `\sum_{n=0}^{\infty} \int_0^1` 中，积分的下限离求和的下限太近。要并排对比，请打开 [`test/latex_font.ipynb`](test/latex_font.ipynb)。

### 7. 恢复 Makie 的默认样式

```julia
set_theme!()
Makie.MathTeXEngine.set_texfont_family!()  # LaTeX 字体：set_theme! 不会重置它
```

## 所有设置

下表列出 `load_makie_config!` 的全部关键字参数。也可以在 Julia REPL 中输入 `?load_makie_config!` 查看。

| 类别 | 关键字 | 默认值 |
|---|---|---|
| 线条 | `lw`（用于 `Lines`、`Errorbars` 和 `VLines`） | `1.8` |
| 字体 | `fontsize` | `16` |
| | `font_regular` | `"Times New Roman"` |
| | `font_latex` | `"STIX"` |
| 标记 | `markersize` | `15` |
| 网格 | `grid`（`false` 表示关闭所有网格） | `true` |
| | `xgridstyle`、`ygridstyle` | `Linestyle([0, 3.7, 5.3])` |
| | `xgridcolor`、`ygridcolor` | `"#b0b0b0"` |
| | `xgridwidth`、`ygridwidth` | `0.8` |
| 刻度数量 | `k_ideal`、`k_min`、`k_max` | `5`、`4`、`10` |
| 刻度 | `xtickalign`、`ytickalign` | `1` |
| | `xminortickalign`、`yminortickalign` | `1` |
| | `xticksmirrored`、`yticksmirrored` | `true` |
| | `xminorticksvisible`、`yminorticksvisible` | `true` |
| | `xminorticks`、`yminorticks` | `IntervalsBetween(5)` |
| 图例 | `legend_backgroundcolor` | `(:white, 0.6)` |
| | `legend_framecolor` | `(:black, 0.3)` |
| | `legend_framewidth` | `1.5` |
| 图形 | `figure_padding` | `nothing`（Makie 默认值） |
| | `palette` | `nothing`（Makie 默认值） |

刻度数量设置同时作用于两个坐标轴。`k_ideal` 是期望的刻度数量，`k_min` 和 `k_max` 是它的下限和上限。

## 运行测试

```julia
using Pkg
Pkg.test("Makierc")
```
