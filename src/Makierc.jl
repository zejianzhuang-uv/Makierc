module Makierc

using Makie

export load_makie_config!, savefig

function savefig(path::String, fig::Figure; transparent=true, kwargs...)
    old = fig.scene.backgroundcolor[]
    if transparent
        fig.scene.backgroundcolor[] = RGBAf(0, 0, 0, 0)
    end
    try
        save(path, fig; kwargs...)
    finally
        fig.scene.backgroundcolor[] = old
    end
end

const MPL_CYCLE = [
    "#009AFA", "#F06073", "#3EA44E", "#ED5E93",
    "#E36F47", "#C371D2", "#AC8E18", "#00AAAE",
    "#C68225", "#00A98D", "#8E971E", "#00A9CC",
    "#9B7FE9", "#618DF6", "#DD65B6", "#6C9F33",
]

const MPL_PALETTE = (color = Makie.to_color.(MPL_CYCLE), patchcolor = Makie.to_color.(MPL_CYCLE))

const GRID_STYLE = Linestyle([0, 3.7, 5.3])

const STIX_DIR = ("assets", "fonts", "STIX")

# Characters that matplotlib's stix fontset draws in italic, but MathTeXEngine takes from the
# upright :math font.
const STIX_ITALIC_CHARS = ['α':'ω'..., 'ϕ', 'ϵ', 'ϑ', 'ϰ', 'ϱ', 'ϖ', 'ħ']

"""
A `FontFamily` that looks like matplotlib's `mathtext.fontset = "stix"`: italic lowercase
Greek letters and an upright `\\mathbf`. The fonts are the ones matplotlib ships.
"""
function stix_font_family()
    MTE = Makie.MathTeXEngine
    font(name) = joinpath(pkgdir(@__MODULE__), STIX_DIR..., name)
    italic = font("STIXGeneralItalic.ttf")
    italic_font = MTE.load_font(italic)
    return MTE.FontFamily(
        Dict(
            :regular => font("STIXGeneral.ttf"),
            :italic => italic,
            :bold => font("STIXGeneralBol.ttf"),
            :bolditalic => font("STIXGeneralBolIta.ttf"),
            :math => font("STIXGeneral.ttf"),
        );
        font_modifiers = merge(
            MTE._default_font_modifiers,
            Dict(:bf => Dict(:italic => :bold, :regular => :bold)),
        ),
        special_chars = Dict{Char, Tuple{String, Int}}(
            c => (italic, MTE.glyph_index(italic_font, c)) for c in STIX_ITALIC_CHARS
        ),
    )
end

latex_font_family(family::Makie.MathTeXEngine.FontFamily) = family
function latex_font_family(name::AbstractString)
    name == "STIX" && return stix_font_family()
    families = Makie.MathTeXEngine.default_font_families
    haskey(families, name) || throw(ArgumentError(
        "unknown font_latex \"$name\", choose one of $(sort!(["STIX"; collect(keys(families))]))",
    ))
    return families[name]
end

"""
    load_makie_config!(; kwargs...)

Apply the Makierc plot style as the current Makie theme. Call it before you create a `Figure`:
the style applies only to figures created after the call.

Every keyword has a default, so `load_makie_config!()` gives the standard style. Each call starts
again from the defaults: overrides from an earlier call are not remembered. A misspelled keyword
raises a `MethodError`.

# Examples

```julia
load_makie_config!()
load_makie_config!(lw = 2.5, fontsize = 18)
load_makie_config!(grid = false, minorticks = false)
load_makie_config!(font_latex = "NewComputerModern")
load_makie_config!(palette = Makierc.MPL_PALETTE, figure_padding = 15)
```

# Keywords

## Lines and markers

| Keyword | Default | Meaning |
|:--------|:--------|:--------|
| `lw` | `1.8` | Line width of `Lines`, `Errorbars` and `VLines`, in points |
| `markersize` | `15` | Marker size of `Scatter` |

## Fonts

| Keyword | Default | Meaning |
|:--------|:--------|:--------|
| `fontsize` | `16` | Font size of all text |
| `font_regular` | `"Times New Roman"` | Font of normal text and tick labels; it must be installed |
| `font_latex` | `"STIX"` | Font of `L"..."` text, see below |

`font_latex` is one of these names, or a `MathTeXEngine.FontFamily` made from your own font files:

- `"STIX"`: looks like matplotlib's `mathtext.fontset: stix`; the fonts come with Makierc
- `"NewComputerModern"`: Makie's default
- `"TeXGyrePagella"`, `"TeXGyreHeros"`, `"LucioleMath"`

Makie keeps this font in a global setting, so `set_theme!()` does not reset it. To reset it, call
`Makie.MathTeXEngine.set_texfont_family!()`.

## Grid

| Keyword | Default | Meaning |
|:--------|:--------|:--------|
| `grid` | `true` | `false` turns off the grids of `Axis`, `Axis3` and `PolarAxis` |
| `xgridstyle`, `ygridstyle` | `Linestyle([0, 3.7, 5.3])` | Dash pattern of the grid lines |
| `xgridcolor`, `ygridcolor` | `"#b0b0b0"` | Colour of the grid lines |
| `xgridwidth`, `ygridwidth` | `0.8` | Width of the grid lines |

## Ticks

| Keyword | Default | Meaning |
|:--------|:--------|:--------|
| `k_ideal` | `5` | Number of major ticks to aim for, on both axes |
| `k_min`, `k_max` | `4`, `10` | Smallest and largest number of major ticks, on both axes |
| `xtickalign`, `ytickalign` | `1` | Major tick direction: `1` is inward, `0` is outward |
| `xticksmirrored`, `yticksmirrored` | `true` | Also draw ticks on the opposite side |
| `minorticks` | `true` | `false` turns off all minor ticks and overrides the keywords below |
| `xminorticksvisible`, `yminorticksvisible` | `true` | Show the minor ticks of one axis |
| `xminortickalign`, `yminortickalign` | `1` | Minor tick direction: `1` is inward, `0` is outward |
| `xminorticks`, `yminorticks` | `IntervalsBetween(5)` | Position of the minor ticks |

## Legend

| Keyword | Default | Meaning |
|:--------|:--------|:--------|
| `legend_backgroundcolor` | `(:white, 0.6)` | Background colour |
| `legend_framecolor` | `(:black, 0.3)` | Frame colour |
| `legend_framewidth` | `1.5` | Frame width |

## Figure

| Keyword | Default | Meaning |
|:--------|:--------|:--------|
| `figure_padding` | `nothing` | Padding around the figure; `nothing` keeps Makie's default |
| `palette` | `nothing` | Colours; `nothing` keeps Makie's default, or use `Makierc.MPL_PALETTE` |
"""
function load_makie_config!(;
    # Lines
    lw = 1.8,
    # Font
    fontsize = 16,
    font_regular = "Times New Roman",
    font_latex = "STIX",
    markersize = 15,
    # Grid
    grid = true,
    xgridstyle = GRID_STYLE,
    xgridcolor = "#b0b0b0",
    xgridwidth = 0.8,
    ygridstyle = GRID_STYLE,
    ygridcolor = "#b0b0b0",
    ygridwidth = 0.8,
    # Ticks, see https://github.com/MakieOrg/Makie.jl/issues/1678
    minorticks = true,
    k_ideal = 5,
    k_min = 4,
    k_max = 10,
    xtickalign = 1,
    xminortickalign = 1,
    xticksmirrored = true,
    xminorticksvisible = true,
    xminorticks = IntervalsBetween(5),
    ytickalign = 1,
    yminortickalign = 1,
    yticksmirrored = true,
    yminorticksvisible = true,
    yminorticks = IntervalsBetween(5),
    # Legend
    legend_backgroundcolor = (:white, 0.6),
    legend_framecolor = (:black, 0.3),
    legend_framewidth = 1.5,
    # Figure
    figure_padding = nothing,
    palette = nothing,
)
    theme = Theme(
        fontsize = fontsize,
        fonts = (; regular = font_regular),
        Axis = (
            # Title
            titlefont = :regular,
            # Grid
            xgridvisible = grid,
            ygridvisible = grid,
            xgridstyle = xgridstyle,
            xgridcolor = xgridcolor,
            xgridwidth = xgridwidth,
            ygridstyle = ygridstyle,
            ygridcolor = ygridcolor,
            ygridwidth = ygridwidth,
            # Ticks
            xticks = WilkinsonTicks(k_ideal; k_min = k_min, k_max = k_max),
            yticks = WilkinsonTicks(k_ideal; k_min = k_min, k_max = k_max),
            xtickalign = xtickalign,
            xminortickalign = xminortickalign,
            xticksmirrored = xticksmirrored,
            xminorticks = xminorticks,
            xminorticksvisible = minorticks && xminorticksvisible,
            ytickalign = ytickalign,
            yminortickalign = yminortickalign,
            yticksmirrored = yticksmirrored,
            yminorticks = yminorticks,
            yminorticksvisible = minorticks && yminorticksvisible,
        ),
        Axis3 = (xgridvisible = grid, ygridvisible = grid, zgridvisible = grid),
        PolarAxis = (rgridvisible = grid, thetagridvisible = grid),
        Scatter = (markersize = markersize,),
        Errorbars = (linewidth = lw,),
        VLines = (linewidth = lw,),
        Lines = (linewidth = lw,),
        Legend = (
            backgroundcolor = legend_backgroundcolor,
            framecolor = legend_framecolor,
            framewidth = legend_framewidth,
        ),
    )
    isnothing(figure_padding) || (theme[:figure_padding] = figure_padding)
    isnothing(palette) || (theme[:palette] = palette)
    Makie.MathTeXEngine.set_texfont_family!(latex_font_family(font_latex))
    return set_theme!(theme)
end

end # module Makierc
