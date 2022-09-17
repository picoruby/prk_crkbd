require "sounder"

# Initialize a Keyboard
kbd = Keyboard.new

# `split=` should happen before `init_pins`
kbd.split = true

kbd.mutual_uart_at_my_own_risk = true

# If your right hand of CRKBD is the "anchor"
# kbd.set_anchor(:right)

# Initialize GPIO assign
kbd.init_pins(
  [ 4, 5, 6, 7 ],            # row0, row1,... respectively
  [ 29, 28, 27, 26, 22, 20 ] # col0, col1,... respectively
)

kbd.add_layer :default, %i[
  KC_ESCAPE KC_Q    KC_W    KC_E        KC_R    KC_T      KC_Y      KC_U      KC_I      KC_O     KC_P      KC_MINUS
  KC_TAB    KC_A    KC_S    KC_D        KC_F    KC_G      KC_H      KC_J      KC_K      KC_L     KC_SCOLON KC_BSPACE
  KC_LSFT   KC_Z    KC_X    KC_C        KC_V    KC_B      KC_N      KC_M      KC_COMMA  KC_DOT   KC_SLASH  KC_RSFT
  KC_NO     KC_NO   KC_NO   ALT_AT      KC_LCTL LOWER_SPC RAISE_ENT SPC_CTL   KC_RGUI   KC_NO    KC_NO     KC_NO
]
kbd.add_layer :raise, %i[
  KC_GRAVE  KC_EXLM KC_AT   KC_HASH     KC_DLR  KC_PERC   KC_CIRC   KC_AMPR   KC_ASTER  KC_LPRN  KC_RPRN   KC_EQUAL
  KC_TAB    KC_LABK KC_LCBR KC_LBRACKET KC_LPRN KC_QUOTE  KC_LEFT   KC_DOWN   KC_UP     KC_RIGHT KC_UNDS   KC_PIPE
  KC_LSFT   KC_RABK KC_RCBR KC_RBRACKET KC_RPRN KC_DQUO   KC_TILD   KC_BSLASH KC_COMMA  KC_DOT   KC_SLASH  KC_RSFT
  KC_NO     KC_NO   KC_NO   ALT_AT      KC_LCTL ADJUST    RAISE_ENT SPC_CTL   RUBY_GUI  KC_NO    KC_NO     KC_NO
]
kbd.add_layer :lower, %i[
  KC_ESCAPE KC_1    KC_2    KC_3        KC_4    KC_5      KC_6      KC_7      KC_8      KC_9     KC_0      KC_EQUAL
  KC_TAB    KC_NO   KC_NO   KC_NO       KC_LPRN KC_QUOTE  KC_DOT    KC_4      KC_5      KC_6     KC_PLUS   KC_BSPACE
  KC_LSFT   KC_RABK KC_RCBR KC_RBRACKET KC_RPRN KC_DQUO   KC_0      KC_1      KC_2      KC_3     KC_SLASH  KC_COMMA
  KC_NO     KC_NO   KC_NO   ALT_AT      KC_LCTL LOWER_SPC ADJUST    SPC_CTL   RUBY_GUI  KC_NO    KC_NO     KC_NO
]
kbd.add_layer :adjust, %i[
  KC_F1     KC_F2   KC_F3   KC_F4       KC_F5   KC_F6     KC_F7     KC_F8     KC_F9     KC_F10   KC_F11    KC_F12
  RGB_TOG   RGB_SPI RGB_HUI RGB_SAI     RGB_VAI RGB_MOD   KC_NO     KC_NO     KC_NO     KC_NO    KC_NO     BOOTSEL
  RGB_TOG   RGB_SPD RGB_HUD RGB_SAD     RGB_VAD RGB_RMOD  KC_NO     KC_NO     KC_NO     KC_NO    KC_NO     KC_NO
  KC_NO     KC_NO   KC_NO   DQ          KC_LCTL ADJUST    ADJUST    SPC_CTL   DQ        KC_NO    KC_NO     KC_NO
]

kbd.define_composite_key :SPC_CTL, %i(KC_SPACE KC_RCTL)

kbd.define_mode_key :ALT_AT,    [ :KC_AT,                    :KC_LALT, 150, 150 ]
kbd.define_mode_key :RAISE_ENT, [ :KC_ENTER,                 :raise,   150, 150 ]
kbd.define_mode_key :LOWER_SPC, [ :KC_SPACE,                 :lower,   150, 150 ]
kbd.define_mode_key :RUBY_GUI,  [ Proc.new { kbd.ruby },     nil,      300, nil ]
kbd.define_mode_key :ADJUST,    [ nil,                       :adjust,  nil, nil ]
kbd.define_mode_key :BOOTSEL,   [ Proc.new { kbd.bootsel! }, nil,      300, nil ]

# Initialize RGBLED with pin, underglow_size, backlight_size and is_rgbw.
rgb = RGB.new(
  0,    # pin number
  6,    # size of underglow pixel
  21,   # size of backlight pixel
  false # 32bit data will be sent to a pixel if true while 24bit if false
)
rgb.effect = :circle
rgb.speed = 28
[
  # Under glow
  # 👇[0, 10],[74,10],[148,10], 👈Starts here and goes left
  # 👉[0, 30],[74,50],[148,50], 👉Connects to back lights
  [148,10],[74,10],[0, 10],[0, 30],[74,50],[148,50],
  #
  # Back light
  #    👇   👈         👇   👈          👇    👈
  # [0, 0],[37, 0],[74, 0],[111, 0],[148, 0],[185, 0],
  # [0,21],[37,21],[74,21],[111,21],[148,21],[185,21],
  # [0,42],[37,42],[74,42],[111,42],[148,42],[185,42],👆
  #    ↑      👆   👈     [129,63],[166,63],[222,63] 👈Starts here and goes upwards
  # The last pixel                       👆    👈
  [222,63],[185,42],[185,21],[185, 0],
  [148, 0],[148,21],[148,42],[166,63],
  [129,63],[111,42],[111,21],[111, 0],
  [74, 0],[74,21],[74,42],
  [37,42],[37,21],[37, 0],
  [0, 0],[0,21],[0,42]
].each do |p|
  rgb.add_pixel(p[0], p[1])
end
kbd.append rgb

sounder = Sounder.new(2)

#
# You only can get the right answer from `Keyboard#anchor?` inside the `Keyboard#on_start`
# callback because anchor or not is undecided until the kbd starts.
#
# The song is split into 2 parts because memory is short if it's united.
#
kbd.on_start do
  if kbd.anchor?
    sounder.add_song :dq_1,
      "T120 L8 Q5 e.e16eddd cdefed efga<c>a gfed.d16d e.e16eece Q8 d2."
    sounder.add_song :dq_2,
      "T148 Q7 L4 r2g8.g16 <cdef g<c2>b8.a16 a.g8r8f+8f+8a8 ge2>e8.e16 eef+g+ a2r8a8b8<c8",
      "d2r8>a8a8<c8 c>bag <Q8e2Q7r8f8e8d8 c2>a<c Q8d2Q7r8e8d8c8 c2>bg <Q8g2Q7r8e8f8g8 Q8a2Q7r8>a8b8<c8f2e2 c2"
  else
    sounder.add_song :dq_1,
      "T120 L8 Q5 c.c16c>ggg eg<cdc>g <cdefaf edc>g.g16g <c.c16cc>e<c Q8 g2."
    sounder.add_song :dq_2,
      "T150 Q7 L4 r2f8.f16 >c>bb-a e2f2 <c>gc<c >c<eg>c e2e2 a<e>c>a",
      "<f+a<d>f+ g2gb eg+be ab<c>a f+a<d>d gg<df ec+>a<e >defd <e>g<e>g <c>gd"
  end
end

song = :dq_1
# When you tap :DQ key, the sounder will play the song's first half.
# When you tap it again, you should hear the second part.
kbd.define_mode_key :DQ,
  [
    Proc.new do
      sounder.play song
      song = (song == :dq_1 ? :dq_2 : :dq_1)
    end,
    nil,
    300,
    nil
  ]
kbd.signal_partner :DQ do
  sounder.play song
  song = (song == :dq_1 ? :dq_2 : :dq_1)
end

kbd.start!
