class TypingGame
  def initialize args
    @args = args
    @score = 0
    @phrase_font_size = 20
    @phrase_x = 640
    @phrase_y = 600
    @phrases = [
      [
        "TYPE THIS AS FAST AS YOU CAN",
        "WOW, YOU DID IT",
        "THE END",
        "...",
        "JUST KIDDING",
        "YOU ARE PRETTY FAST",
        "OK",
        "CALM DOWN",
        "SERIOUSLY",
        "I THINK YOU ARE A ROBOT",
        "01010111 01010100 01000110",
        "HMMM",
        "MAYBE YOU ARE",
        "AAHHHHH"
      ],
      [
        "TYPE THIS AS FAST AS YOU CAN",
        "LET ME TELL YOU A STORY",
        "ALL ABOUT HOW",
        "MY LIFE GOT FLIPPED",
        "TURNED UPSIDE DOWN",
        "AND I'D LIKE TO TAKE A MINUTE",
        "JUST SIT RIGHT THERE",
        "WAIT",
        "HAVE YOU HEARD THIS ONE BEFORE",
        "YOU DON'T LOOK IMPRESSED"
      ],
      [
        "TYPE THIS AS FAST AS YOU CAN",
        "I'M IMPRESSED",
        "DID YOU LEARN TO TOUCH TYPE",
        "AT A PHD LEVEL",
        "BECAUSE YOU SEEM REALLY FAST",
        "OH, ON SECOND THOUGHT",
        "YOU ARE RATHER AVERAGE",
        "I TAKE IT BACK",
        "OH, YOU ARE TRYING VERY HARD"
      ],
      [
        "TYPE THIS AS FAST AS YOU CAN",
        "I'VE HEARD ABOUT YOU",
        "YOU ARE THAT PERSON",
        "WHO IS REALLY FAST AT TYPING",
        "I'M STILL WAITING",
        "FOR YOU TO IMPRESS ME THOUGH",
        "YOUR KEYBOARD SOUNDS RATHER LOUD",
        "WAS IT EXPENSIVE",
        "YOU SEEM LIKE",
        "A RED SWITCH KIND OF PERSON"
      ]
    ]
    @phrase_set = rand(@phrases.length)
    @phrase_index = 0
    @random_explosion_angle = 0
    @show_space_bar_prompt = false
    @count_down = 20 * 60
    @explode = false
    @gameover = false
    @render_x = 0
    @render_y = 0
    @render_angle = 0
  end  

  def render_background
    @args.outputs.solids << {
      x: 0,
      y: 0,
      w: 1280,
      h: 720,
      r: 0,
      g: 0,
      b: 0,
      a: 255
    }
  end

  def render_labels
    labels = []

    # Main phrase
    if @gameover == true
      labels << {
        x: @phrase_x,
        y: @phrase_y,
        text: completed? ? "MAXIMUM POINTS!" : "TIME'S UP!",
        size_enum: 30,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255,
        a: 255
      }

      # Final score
      labels << {
        x: @phrase_x,
        y: 360,
        text: "Score: #{@score}",
        size_enum: 40,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255,
        a: 255
      }
    else
      # Main phrase
      labels << {
        x: @phrase_x,
        y: @phrase_y,
        text: @phrases[@phrase_set][@phrase_index],
        size_enum: @phrase_font_size,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255,
        a: 255
      }

      # Score
      labels << {
        x: 75,
        y: 75,
        text: "Score: #{@score}",
        size_enum: 10,
        alignment_enum: 3,
        r: 255,
        g: 255,
        b: 255,
        a: 255
      }

      # Timer
      labels << {
        x: 1205,
        y: 75,
        text: "Time left: #{(@count_down.idiv 60)}",
        size_enum: 10,
        alignment_enum: 2,
        r: 255,
        g: 255,
        b: 255,
        a: 255
      }

      # Space bar prompt
      if @show_space_bar_prompt
        labels << {
          x: 640,
          y: @phrase_y - 80,
          text: "(space bar)",
          size_enum: 10,
          alignment_enum: 1,
          r: 255,
          g: 255,
          b: 255,
          a: 255
        }
      end
    end

    # Reset text
    labels << {
      x: 640,
      y: 75,
      text: "'ESC' to reset",
      size_enum: 10,
      alignment_enum: 1,
      r: 255,
      g: 255,
      b: 255,
      a: 255
    }

    @args.render_target(:game).labels << labels
  end

  def render_explosion
    return if @gameover

    if @explode
      @args.state.start_looping_at = @args.state.tick_count
    end

    number_of_sprites = 7
    number_of_frames_to_show_each_sprite = 2
    does_sprite_loop = false

    sprite_index = @args.state
                      .start_looping_at
                      .frame_index number_of_sprites,
                                    number_of_frames_to_show_each_sprite,
                                    does_sprite_loop

    sprite_index ||= 0

    if sprite_index > 0
      phrase_size = @args.gtk.calcstringbox(@phrases[@phrase_set][@phrase_index], @phrase_font_size)

      @args.render_target(:game).sprites << { 
        x: @phrase_x - (phrase_size[0] / 2) - 50,
        y: @phrase_y - (phrase_size[1] / 2) - 50,
        w: 100,
        h: 100,
        path: "sprites/explosions/explosion-#{sprite_index}.png",
        angle: @random_explosion_angle
      }
    end
  end

  def render_target
    return if @gameover
    
    current_phrase = @phrases[@phrase_set][@phrase_index]

    if current_phrase.length > 0
      phrase_size = @args.gtk.calcstringbox(current_phrase, @phrase_font_size)
      letter_size = @args.gtk.calcstringbox(current_phrase.chars.first, @phrase_font_size)
  
      @args.render_target(:game).solids << {
        x: @phrase_x - (phrase_size[0] / 2) - (letter_size[0] / 2) + 10,
        y: @phrase_y - (phrase_size[1] / 2) - (letter_size[1] / 2),
        w: letter_size[0],
        h: letter_size[1],
        r: 127,
        g: 127,
        b: 127
      }
    end
  end

  def render_scene
    if @explode
      max = 20
      min = -20
      @render_x = rand * (max - min) + min
      @render_y = rand * (max - min) + min
      @render_angle = rand * (5 - -5) + -5

    else
      @render_x += 1 if @render_x < 0
      @render_x -= 1 if @render_x > 0
      @render_y += 1 if @render_y < 0
      @render_y -= 1 if @render_y > 0
      @render_angle += 1 if @render_angle < 0
      @render_angle -= 1 if @render_angle > 0
    end

    @args.outputs.sprites << {
      x: @render_x,
      y: @render_y,
      w: 1280,
      h: 720,
      path: :game,
      angle: @render_angle
    }

    @explode = false
  end

  def render
    render_background
    render_explosion
    render_target
    render_labels
    render_scene
  end

  def detect_key letter
    case letter
      when "0" then :zero
      when "1" then :one
      when " " then :space
      when "," then :comma
      when "." then :period
      when "'" then :single_quotation_mark
      when "!" then :exclamation_point
      when "?" then :question_mark
      else letter
    end
  end

  def completed?
    @phrase_index >= @phrases[@phrase_set].length
  end

  def iterate
    return if @gameover

    current_phrase = @phrases[@phrase_set][@phrase_index]

    if current_phrase.length > 0
      next_key = detect_key(current_phrase.downcase.chars.first)

      @show_space_bar_prompt = next_key == :space

      if @args.inputs.keyboard.key_down.send(:"#{next_key}")
        @phrases[@phrase_set][@phrase_index] = current_phrase[1..-1]
        @score += 1
        @explode = true
        @random_explosion_angle = [45, 90, 135, 180, 225, 270, 315].sample
        @args.outputs.sounds << "sounds/boom.wav"
      end
    else
      @phrase_index += 1
    end

    if @score > 0
      @count_down -= 1
    end

    if @count_down < 0 || completed?
      @args.outputs.sounds << "sounds/end.wav"
      @gameover = true
    end
  end

  def tick args
    @args = args
    iterate
    render
  end
end

def tick args
  if args.inputs.keyboard.key_down.escape
    $game = TypingGame.new args
  end

  $game ||= TypingGame.new args
  $game.tick args
end
