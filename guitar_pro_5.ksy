meta:
  id: guitar_pro_5
  application: Guitar Pro 5
  endian: le
  file-extension: gp5
  license: MIT
  xref:
    justsolve: Guitar_Pro_5
doc: |
  Guitar Pro 5 ....
seq:
  - id: version
    type: version_information
  - id: score
    type: score_information
  - id: lyrics
    type: lyrics_information
  - id: rse_master
    type: rse_instrument
    if: version.minor_version.to_i > 0
  - id: page_setup
    type: page_setup_information
  - id: tempo_string
    type: int_byte_str
  - id: tempo_int
    type: s4
  - id: hide_tempo
    type: s1
    if: version.minor_version.to_i > 0
  - id: key ### TODO: Make this a proper enum
    type: s1
  - id: octave
    type: s4
  - id: midi_ports
    type: midi_port
    repeat: expr
    repeat-expr: 4
  - id: directions
    type: direction
    repeat: expr
    repeat-expr: 19
  - id: reverb
    type: s4
  - id: measure_count
    type: s4
  - id: track_count
    type: s4
  - id: measure_headers
    type: measure_header(_index)
    repeat: expr
    repeat-expr: measure_count
  - id: tracks
    type: track(version.minor_version.to_i, _index)
    repeat: expr
    repeat-expr: track_count
# instances:
types:
  version_information:
    seq:
      - id: version_length
        type: s1
      - id: magic1
        contents: 'FICHIER GUITAR PRO v'
      - id: major_version
        type: str
        encoding: UTF-8
        size: 1
      - id: magic2
        contents: '.'
      - id: minor_version
        type: str
        encoding: UTF-8
        size: 2
      - id: placeholder
        type: s1
        repeat: expr
        repeat-expr: 30-version_length
  byte_str:
    seq:
      - id: len
        type: s1
      - id: value
        type: str
        encoding: UTF-8
        size: len
    doc: |
      ByteString. Represents a string structure containing the length of
      the string, stored in 8 bit integer, followed by UTF-8 encoded string data.
  int_str:
    seq:
      - id: len
        type: s4
      - id: value
        type: str
        encoding: UTF-8
        size: len
  int_byte_str:
    seq:
      - id: len
        type: s4
      - id: value
        type: byte_str
        size: len
    doc: |
      IntByteString. Represents a string structure containing the length of
      the string, stored in 32 bit integer, followed by UTF-8 encoded string data.
  score_information:
    seq:
      - id: title
        type: int_byte_str
      - id: subtitle
        type: int_byte_str
      - id: interpret
        type: int_byte_str
      - id: album
        type: int_byte_str
      - id: words
        type: int_byte_str
      - id: music
        type: int_byte_str
      - id: copyright
        type: int_byte_str
      - id: author
        type: int_byte_str
      - id: instructions
        type: int_byte_str
      - id: noicecount #Typo on purpose
        type: s4
      - id: notices
        type: int_byte_str
        repeat: expr
        repeat-expr: noicecount
  lyrics_line:
    seq:
      - id: measure_start
        type: s4
      - id: content
        type: int_str
  lyrics_information:
    seq:
      - id: lyricstrack
        type: s4
      - id: lyrics
        type: lyrics_line
        repeat: expr
        repeat-expr: 5 #Hardcoded
  rse_instrument:
    seq:
      - id: volume
        type: s4
      - id: unused
        type: s4
      - id: bands
        type: s1
        repeat: expr
        repeat-expr: 10 # Hardcoded for master
      - id: gain
        type: s1
  page_setup_information:
    seq:
      - id: width
        type: s4
      - id: height
        type: s4
      - id: padding_left
        type: s4
      - id: padding_right
        type: s4
      - id: padding_top
        type: s4
      - id: padding_bottom
        type: s4
      - id: size_proportion
        type: s4
      - id: header_footer
        type: s2
      - id: title
        type: int_byte_str
      - id: subtitle
        type: int_byte_str
      - id: artist
        type: int_byte_str
      - id: album
        type: int_byte_str
      - id: words
        type: int_byte_str
      - id: music
        type: int_byte_str
      - id: words_and_music
        type: int_byte_str
      - id: copyright
        type: int_byte_str
        repeat: expr
        repeat-expr: 2
      - id: page_number
        type: int_byte_str
  midi_channel:
    seq:
      - id: instrument
        type: s4
      - id: volume
        type: s1
      - id: balance
        type: s1
      - id: chorus
        type: s1
      - id: reverb
        type: s1
      - id: phaser
        type: s1
      - id: tremolo
        type: s1
      - id: blank1
        type: s1
      - id: blank2
        type: s1
  midi_port:
    seq:
      - id: channels
        type: midi_channel
        repeat: expr
        repeat-expr: 16
  direction: ### TODO: Add in enum for direction names
    seq:
      - id: measure
        type: s2
  typed_color:
    seq:
      - id: red
        type: u1
      - id: green
        type: u1
      - id: blue
        type: u1
      - id: alpha
        type: u1
  typed_marker:
    seq:
      - id: name
        type: int_byte_str
      - id: color
        type: typed_color
  measure_header:
    params:
      - id: measure_index
        type: u4
    seq:
      - id: skipped_byte
        type: u1
        if: measure_index > 0
      - id: flags
        type: u1
      - id: numerator
        type: u1
        if: "flags & 0x01 != 0"
      - id: denominator
        type: u1
        if: "flags & 0x02 != 0"
      - id: end_repeat
        type: u1
        if: "flags & 0x08 != 0"
      - id: alternate_ending
        type: u1
        if: "flags & 0x10 != 0"
      - id: marker
        type: typed_marker
        if: "flags & 0x20 != 0"
      - id: tonality
        type: u1
        repeat: expr
        repeat-expr: 2
        if: "flags & 0x40 != 0"
      - id: time_signature_beams
        type: u1
        repeat: expr
        repeat-expr: 4
        if: "flags & 0x03 != 0"
      - id: unused
        type: u1
        if: "flags & 0x10 == 0"
      - id: triplet_feel
        type: u1
    instances:
      begin_repeat:
        value: (flags & 0x04)
      double_bar:
        value: (flags & 0x80)
  rse_track_instrument:
    params:
      - id: version_minor
        type: u4
    seq:
      - id: midi_instrument
        type: u4
      - id: unknown
        type: u4
      - id: sound_bank
        type: u4
      - id: effect_number_v0
        type: u2
        if: version_minor == 0
      - id: effect_skip_v0
        type: u1
        if: version_minor == 0
      - id: effect_number_v1
        type: u4
        if: version_minor != 0
  track:
    params:
      - id: version_minor
        type: u4
      - id: track_index
        type: u4
    seq:
      - id: skipped_byte
        type: u1
        if: (track_index == 0) or (version_minor == 0)
      - id: flags
        type: u1
      - id: name
        type: byte_str
      - id: placeholder
        type: s1
        repeat: expr
        repeat-expr: 40 - name.len
      - id: string_count
        type: u4
      - id: tunings
        type: u4
        repeat: expr
        repeat-expr: 7
      - id: midi_port
        type: u4
      - id: channel
        type: u4
        repeat: expr
        repeat-expr: 2
      - id: fret_count
        type: u4
      - id: capo_fret
        type: u4
      - id: color
        type: typed_color
      - id: display_flags
        type: s2
      - id: auto_accentuation
        type: u1
      - id: midi_bank
        type: u1
      - id: humanize
        type: u1
      - id: unknown
        type: u4
        repeat: expr
        repeat-expr: 6
      - id: rse
        type: rse_track_instrument(version_minor)
      - id: rse_eq_bands
        type: s1
        repeat: expr
        repeat-expr: 3
      - id: rse_gain
        type: s1
      - id: effect_name
        type: int_byte_str
        if: version_minor > 0
      - id: effect_category
        type: int_byte_str
        if: version_minor > 0
# enums:
