require "via"

kbd = Keyboard.new
kbd.via = true
kbd.via_layer_count = 4
kbd.split = true
kbd.mutual_uart_at_my_own_risk = true
kbd.set_anchor(:right)
kbd.init_pins(
  [ 4, 5, 6, 7 ],            # row0, row1,... respectively
  [ 29, 28, 27, 26, 22, 20 ] # col0, col1,... respectively
)

rgb = RGB.new(
  0,
  6,    # size of underglow pixel
  21,   # size of backlight pixel
  false
)
rgb.effect = :swirl
rgb.speed = 28
kbd.append rgb

kbd.define_mode_key :VIA_FUNC0, [ Proc.new { kbd.bootsel! }, nil, 300, nil ]
kbd.define_mode_key :VIA_FUNC1, [ :KC_ENTER, :VIA_LAYER1, 150, 150 ]
kbd.define_mode_key :VIA_FUNC2, [ :KC_SPACE, :VIA_LAYER2, 150, 150 ]
kbd.define_mode_key :VIA_FUNC3, [ :KC_NO,    :VIA_LAYER3, 150, 150 ]
kbd.define_mode_key :VIA_FUNC4, [ Proc.new { PicoRubyVM.print_alloc_stats }, nil, 300, nil ]

kbd.start!
