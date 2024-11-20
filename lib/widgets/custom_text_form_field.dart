import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField(
      {super.key,
      this.alignment,
      this.width,
      this.boxDecoration,
      this.scrollPadding,
      this.controller,
      this.focusNode,
      this.autoFocus = false,
      this.textStyle,
      this.obsecureText = false,
      this.readOnly = false,
      this.onTap,
      this.textInputAction = TextInputAction.next,
      this.textInputType = TextInputType.text,
      this.maxLines,
      this.hintText,
      this.hintStyle,
      this.labelText,
      this.labelStyle,
      this.prefix,
      this.preficConstraints,
      this.suffix,
      this.suffixConstraints,
      this.contentPadding,
      this.borderDecoration,
      this.fillColor,
      this.filled = false,
      this.onChange,
      this.validator,
      this.inputFormatters});
  final Alignment? alignment;
  final double? width;
  final BoxDecoration? boxDecoration;
  final TextEditingController? scrollPadding;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool? autoFocus;
  final TextStyle? textStyle;
  final bool? obsecureText;
  final bool? readOnly;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final int? maxLines;
  final String? hintText;
  final TextStyle? hintStyle;
  final String? labelText;
  final TextStyle? labelStyle;
  final Widget? prefix;
  final BoxConstraints? preficConstraints;
  final Widget? suffix;
  final BoxConstraints? suffixConstraints;
  final EdgeInsets? contentPadding;
  final InputBorder? borderDecoration;
  final Color? fillColor;
  final bool? filled;
  final FormFieldValidator<String>? validator;
  final void Function(String value)? onChange;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment ?? Alignment.center,
            child: textFormFieldWidget(context),
          )
        : textFormFieldWidget(context);
  }

  Widget textFormFieldWidget(BuildContext context) => Container(
        width: width ?? double.maxFinite,
        decoration: boxDecoration,
        child: TextFormField(
          scrollPadding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          controller: controller,
          focusNode: focusNode,
          onTapOutside: (event) {
            if (focusNode != null) {
              focusNode?.unfocus();
            } else {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          autofocus: autoFocus!,
          style: textStyle ??
              const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Red Hat Display',
                fontWeight: FontWeight.w300,
              ),
          obscureText: obsecureText!,
          readOnly: readOnly!,
          onTap: () {
            onTap?.call();
          },
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          keyboardType: textInputType,
          maxLines: maxLines ?? 1,
          decoration: decoration,
          validator: validator,
          onChanged: onChange,
        ),
      );
  InputDecoration get decoration => InputDecoration(
        hintText: hintText ?? "",
        hintStyle: hintStyle ??
            const TextStyle(
              color: Color(0XFF767676),
              fontSize: 16,
              fontFamily: 'Red Hat Display',
              fontWeight: FontWeight.w400,
            ).copyWith(
              color: const Color(0XFFC4C4C4),
            ),
        labelText: labelText ?? "",
        labelStyle: labelStyle,
        prefixIcon: prefix,
        prefixIconConstraints: preficConstraints,
        suffixIcon: suffix,
        suffixIconConstraints: suffixConstraints,
        isDense: true,
        contentPadding: contentPadding ?? const EdgeInsets.all(2),
        fillColor: fillColor,
        filled: filled,
        border: borderDecoration ??
            const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Color(0XFF122C50),
              ),
            ),
        enabledBorder: borderDecoration ??
            const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Color(0XFF122C50),
              ),
            ),
        focusedBorder:
            (borderDecoration ?? const UnderlineInputBorder()).copyWith(
          borderSide: const BorderSide(
            color: Color(0XFF122C50),
            width: 1,
          ),
        ),
      );
}
