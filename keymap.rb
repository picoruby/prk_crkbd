# Wait until Keyboard class is ready
while !$mutex
  relinquish
end

# Initialize a Keyboard
kbd = Keyboard.new

# `split=` should happen before `init_pins`
kbd.split = true
#kbd.set_anchor(:right)

# Initialize GPIO assign
kbd.init_pins(
  [ 4, 5, 6, 7 ],            # row0, row1,... respectively
  [ 29, 28, 27, 26, 22, 20 ] # col0, col1,... respectively
)

# default layer should be added at first
kbd.add_layer :default, [
  %i(KC_ESCAPE KC_Q    KC_W    KC_E        KC_R      KC_T     KC_Y      KC_U      KC_I      KC_O     KC_P      KC_MINUS),
  %i(KC_TAB    KC_A    KC_S    KC_D        KC_F      KC_G     KC_H      KC_J      KC_K      KC_L     KC_SCOLON KC_BSPACE),
  %i(KC_LSFT   KC_Z    KC_X    KC_C        KC_V      KC_B     KC_N      KC_M      KC_COMMA  KC_DOT   KC_SLASH  KC_RSFT),
  %i(KC_NO     KC_NO   KC_NO   ALT_AT      CTL_EQ  LOWER_SPC  RAISE_ENT SPC_CTL   KC_RGUI  KC_NO     KC_NO     KC_NO),
]
kbd.add_layer :raise, [
  %i(KC_GRAVE  KC_EXLM KC_AT   KC_HASH     KC_DLR    KC_PERC  KC_CIRC   KC_AMPR   KC_ASTER  KC_LPRN  KC_RPRN   KC_MIUNS),
  %i(KC_TAB    KC_LABK KC_LCBR KC_LBRACKET KC_LPRN   KC_QUOTE KC_LEFT   KC_DOWN   KC_UP     KC_RIGHT KC_UNDS   KC_PIPE),
  %i(KC_LSFT   KC_RABK KC_RCBR KC_RBRACKET KC_RPRN   KC_DQUO  KC_TILD   KC_BSLASH KC_COMMA  KC_DOT   KC_SLASH  KC_RSFT),
  %i(KC_NO     KC_NO   KC_NO   ALT_AT      CTL_EQ  LOWER_SPC  RAISE_ENT SPC_CTL   KC_RGUI  KC_NO     KC_NO     KC_NO),
]
kbd.add_layer :lower, [
  %i(KC_ESCAPE KC_1    KC_2    KC_3        KC_4      KC_5     KC_6      KC_7      KC_8      KC_9     KC_0      KC_MIUNS),
  %i(KC_TAB    KC_F2   KC_F10  KC_F12      KC_LPRN   KC_QUOTE KC_DOT    KC_4      KC_5      KC_6     KC_PLUS   KC_BSPACE),
  %i(KC_LSFT   KC_RABK KC_RCBR KC_RBRACKET KC_RPRN   KC_DQUO  KC_0      KC_1      KC_2      KC_3     KC_SLASH  KC_COMMA),
  %i(KC_NO     KC_NO   KC_NO   ALT_AT      CTL_EQ  LOWER_SPC  RAISE_ENT SPC_CTL   KC_RGUI  KC_NO     KC_NO     KC_NO),
]
#
#                   Your custom     Keycode or             Keycode (only modifiers)             Release time      Re-push time
#                   key name        Array of Keycode       or Proc                              threshold(ms)     threshold(ms)
#                                   or Proc                while you                            to consider as    to consider as
#                                   when you click         keep press                           `click the key`   `hold the key`
kbd.define_mode_key :ALT_AT,      [ :KC_AT,                :KC_LALT                           , 120,              150 ]
kbd.define_mode_key :CTL_EQ,      [ :KC_EQUAL,             :KC_LCTL                           , 120,              150 ]
kbd.define_mode_key :SPC_CTL,     [ %i(KC_SPACE KC_RCTL),  :KC_RCTL                           , 120,              150 ]
kbd.define_mode_key :RAISE_ENT,   [ :KC_ENTER,             Proc.new { kbd.hold_layer :raise  }, 120,              150 ]
kbd.define_mode_key :LOWER_SPC,   [ :KC_SPACE,             Proc.new { kbd.hold_layer :lower  }, 120,              150 ]
#kbd.define_mode_key :ADJUST,      [ nil,                   Proc.new { kbd.hold_layer :adjust }, nil,              nil ]
                                                            # ^^^^^^^^^^ `hold_layer` will "hold" layer while pressed

#
# Alternatively, you can also write like:
#
# kbd.add_layer :default, [
#   %i(KC_A SHIFT_RAISE),
#   %i(KC_B SHIFT_SPACE),
# ]
# kbd.add_layer :raise, [
#   %i(KC_C SHIFT_LOWER),
#   %i(KC_D SPACE_LOWER),
# ]
# kbd.add_layer :lower, [
#   %i(KC_E SHIFT_DEFAULT),
#   %i(KC_F LOWER_SPACE),
# ]
# kbd.define_mode_key :SHIFT_RAISE,   [ Proc.new { kbd.lock_layer :raise },   :KC_RSFT,         200,              200 ]
# kbd.define_mode_key :SHIFT_LOWER,   [ Proc.new { kbd.lock_layer :lower },   :KC_RSFT,         200,              200 ]
# kbd.define_mode_key :SHIFT_DEFAULT, [ Proc.new { kbd.lock_layer :default }, :KC_RSFT,         200,              200 ]
#                                                      ^^^^^^^^^^ `lock_layer` will "lock" layer to specified one
# kbd.define_mode_key :SHIFT_SPACE,   [ :KC_SPACE,                            :KC_LSFT,         300,              400 ]
# kbd.define_mode_key :SPACE_LOWER,   [ Proc.new { kbd.lower_layer },         :KC_LCTL,         200,              200 ]
#
# Other than `hold_layer` and `lock_layer`, `raise_layer` and `lower_layer` will switch current layer in order
#


# `before_report` will work just right before reporting what keys are pushed to USB host.
# You can use it to hack data by adding an instance method to Keyboard class by yourself.
# ex) Use Keyboard#before_report filter if you want to input `":" w/o shift` and `";" w/ shift`
#kbd.before_report do
#  kbd.invert_sft if kbd.keys_include?(:KC_SCOLON)
#  # You'll be also able to write `invert_ctl`, `invert_alt` and `invert_gui`
#end

# Initialize RGBLED with pin, underglow_size, backlight_size and is_rgbw.
#kbd.init_rgb(
#  0,    # pin number
#  6,    # size of underglow pixel
#  21,   # size of backlight pixel
#  false # 32bit data will be sent to a pixel if true while 24bit if false
#)

kbd.start!
