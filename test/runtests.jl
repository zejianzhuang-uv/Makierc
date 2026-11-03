using Test
using Makie
using Makierc
using Makie.LaTeXStrings

current(block, key) = to_value(Makie.current_default_theme()[block][key])
current(key) = to_value(Makie.current_default_theme()[key])

@testset "load_makie_config!" begin
    @testset "defaults are the package style" begin
        load_makie_config!()
        @test current(:fontsize) == 16
        @test to_value(current(:fonts).regular) == "Times New Roman"
        @test current(:Lines, :linewidth) == 1.8
        @test current(:Scatter, :markersize) == 15
        @test current(:Axis, :xtickalign) == 1
        @test current(:Legend, :framewidth) == 1.5
    end

    @testset "keywords override the matching setting" begin
        load_makie_config!(lw = 2.5, fontsize = 20, markersize = 8)
        @test current(:Lines, :linewidth) == 2.5
        @test current(:Errorbars, :linewidth) == 2.5
        @test current(:VLines, :linewidth) == 2.5
        @test current(:fontsize) == 20
        @test current(:Scatter, :markersize) == 8
    end

    @testset "an override keeps the other settings" begin
        load_makie_config!(fontsize = 20)
        @test current(:Lines, :linewidth) == 1.8
        @test current(:Axis, :xticksmirrored) == true
    end

    @testset "a new call does not remember the previous one" begin
        load_makie_config!(lw = 2.5)
        load_makie_config!()
        @test current(:Lines, :linewidth) == 1.8
    end

    @testset "k_ideal sets the tick target" begin
        load_makie_config!(k_ideal = 7)
        @test current(:Axis, :xticks).k_ideal == 7
        @test current(:Axis, :yticks).k_ideal == 7
    end

    @testset "palette and figure_padding are opt-in" begin
        load_makie_config!(figure_padding = 30, palette = Makierc.MPL_PALETTE)
        @test current(:figure_padding) == 30
        @test to_value(current(:palette)[:color]) == Makierc.MPL_PALETTE.color
    end

    @testset "font_latex sets the font of LaTeX text" begin
        MTE = Makie.MathTeXEngine
        chars(str) = [e[1] for e in MTE.generate_tex_elements(str) if e[1] isa MTE.TeXChar]
        font_of(str) = only(unique((c.font.family_name, c.font.style_name) for c in chars(str)))

        @testset "the default looks like matplotlib's mathtext.fontset = stix" begin
            load_makie_config!()
            @test font_of(L"\mathrm{a}1") == ("STIXGeneral", "Regular")
            @test font_of(L"x") == ("STIXGeneral", "Italic")
            @test font_of(L"\alpha\pi\epsilon") == ("STIXGeneral", "Italic")
            @test font_of(L"\mathbf{P}") == ("STIXGeneral", "Bold")
        end

        @testset "common math symbols have a glyph" begin
            load_makie_config!()
            str = L"\alpha\omega\hbar\Lambda\Sigma\sum\int\sqrt{x}\frac{a}{b}\leq\geq\infty\pm\times\to\partial\nabla\ell"
            @test all(c -> c.glyph_id != 0, chars(str))
        end

        @testset "a built-in family can be chosen by name" begin
            load_makie_config!(font_latex = "TeXGyrePagella")
            @test font_of(L"\mathrm{a}") == ("TeX Gyre Pagella", "Regular")
        end

        @testset "a custom FontFamily can be passed" begin
            load_makie_config!(font_latex = MTE.FontFamily("TeXGyreHeros"))
            @test font_of(L"\mathrm{a}") == ("TeX Gyre Heros Makie", "Regular")
        end

        @testset "a new call does not remember the previous font" begin
            load_makie_config!(font_latex = "TeXGyrePagella")
            load_makie_config!()
            @test font_of(L"\mathrm{a}") == ("STIXGeneral", "Regular")
        end

        @testset "an unknown name raises an error and keeps the font" begin
            load_makie_config!()
            @test_throws ArgumentError load_makie_config!(font_latex = "NoSuchFont")
            @test font_of(L"\mathrm{a}") == ("STIXGeneral", "Regular")
        end
    end

    @testset "misspelled keywords raise an error" begin
        @test_throws MethodError load_makie_config!(linewidth_typo = 2)
    end
end
