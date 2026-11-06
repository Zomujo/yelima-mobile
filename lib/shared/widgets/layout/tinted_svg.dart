import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics_compat.dart'
    show RenderingStrategy;

/// A one-colour SVG icon. Drawn from a cached image, so tinting it does not
/// cost an extra off-screen drawing pass on every frame.
class TintedSvg extends StatelessWidget {
  const TintedSvg(this.asset, {super.key, required this.color, this.size});

  final String asset;
  final Color color;

  /// Width and height; null uses the SVG's own size.
  final double? size;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        asset,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        renderingStrategy: RenderingStrategy.raster,
      );
}
