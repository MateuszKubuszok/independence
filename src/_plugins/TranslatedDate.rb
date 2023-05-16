require 'date'

module Jekyll
  module TranslatedDate

    @@lang = nil
    @@default_format = nil

    def translate_date(date_value, lang, format)
      unless @@lang
        @@lang ||= @context.registers[:site]['lang']
        @@lang ||= 'en'
      end
      lang ||= @@lang

      unless @@default_format
        @@default_format ||= @context.registers[:site]['date_format']
        @@default_format ||= '%b %-d, %Y'
      end
      format ||= @default_format

      @locales ||= @context.registers[:site]['locales']

      parsed_date = DateTime.strptime(date_value)

      num_day = parsed_date.strftime('%w').to_i
      num_month = parsed_date.strftime('%-m').to_i - 1

      translated_date_format = format
      if locales[lang]&.abbreviated_weekday[num_day]
        translated_date_format = translated_date_format.replace('%a', locales[lang].abbreviated_weekday[num_day])
      end
      if locales[lang]&.full_weekday[num_day]
        translated_date_format = translated_date_format.replace('%A', locales[lang].full_weekday[num_day])
      end
      if locales[lang]&.abbreviated_month[num_month]
        translated_date_format = translated_date_format.replace('%b', locales[lang].abbreviated_month[num_month])
      end
      if locales[lang]&.full_month[num_month]
        translated_date_format = translated_date_format.replace('%B', locales[lang].full_month[num_month])
      end

      parsed_date.strftime(translated_date_format)
    end
  end
end

Liquid::Template.register_filter(Jekyll::TranslatedDate)
