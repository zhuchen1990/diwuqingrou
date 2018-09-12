def heart_text_animation(words="I LOVE U"):
    import time
    for c in words.split():
        line = []
        for y in range(15, -15, -1):
            line_c = []
            letters = ''
            for x in range(-30, 30):
                expression = ((x * 0.05) ** 2 + (y * 0.1) ** 2 - 1) ** 3 - (x * 0.05) ** 2 * (y * 0.1) ** 3
                if expression <= 0:
                    letters += c[(x - y) % len(c)]
                else:
                    letters += ' '
            line_c.append(letters)
            line += line_c
        print('\n'.join(line))
        time.sleep(1)
