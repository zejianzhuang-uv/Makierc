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

"""
    load_makie_config!(; kwargs...)

Apply the Makierc plot style as the current Makie theme. Every setting has a default, so
`load_makie_config!()` gives the standard style. Each call starts again from the defaults:
overrides from an earlier call are not remembered.

```julia
load_makie_config!()
load_makie_config!(lw = 2.5, fontsize = 18)
load_makie_config!(palette = Makierc.MPL_PALETTE, figure_padding = 15)
```

# Keywords

- Lines: `lw` (`Lines`, `Errorbars` and `VLines` line width, in points)
- Font: `fontsize`, `font_regular`
- Markers: `markersize`
- Grid: `xgridstyle`, `xgridcolor`, `xgridwidth`, `ygridstyle`, `ygridcolor`, `ygridwidth`
- Tick count: `k_ideal`, `k_min`, `k_max` (Wilkinson tick target and limits, on both axes)
- Ticks: `xtickalign`, `xminortickalign`, `xticksmirrored`, `xminorticksvisible`, `xminorticks`,
  and the same for `y`
- Legend: `legend_backgroundcolor`, `legend_framecolor`, `legend_framewidth`
- Figure: `figure_padding`, `palette` (`nothing` keeps Makie's default)
"""
function load_makie_config!(;
    # Lines
    lw = 1.8,
    # Font
    fontsize = 16,
    font_regular = "CMU Serif",
    markersize = 15,
    # Grid
    xgridstyle = GRID_STYLE,
    xgridcolor = "#b0b0b0",
    xgridwidth = 0.8,
    ygridstyle = GRID_STYLE,
    ygridcolor = "#b0b0b0",
    ygridwidth = 0.8,
    # Ticks, see https://github.com/MakieOrg/Makie.jl/issues/1678
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
            xminorticksvisible = xminorticksvisible,
            ytickalign = ytickalign,
            yminortickalign = yminortickalign,
            yticksmirrored = yticksmirrored,
            yminorticks = yminorticks,
            yminorticksvisible = yminorticksvisible,
        ),
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
    return set_theme!(theme)
end

end # module Makierc
