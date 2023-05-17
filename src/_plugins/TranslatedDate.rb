require 'date'

module Jekyll
  module TranslatedDate

    @@lang = nil
    @@default_format = nil

    def translated_date(parsed_date, lang, format)
      unless @@lang
        @@lang ||= @context.registers[:site].config['lang']
        @@lang ||= 'en'
      end
      lang ||= @@lang

      unless @@default_format
        @@default_format ||= @context.registers[:site].config['date_format']
        @@default_format ||= '%b %-d, %Y'
      end
      format ||= @@default_format

      @locales ||= @context.registers[:site].data['locales']
      locale = @locales[lang]

      num_day = parsed_date.strftime('%w').to_i
      num_month = parsed_date.strftime('%-m').to_i - 1

      translated_date_format = format
      if locale['abbreviated_weekday'] && locale['abbreviated_weekday'][num_day]
        translated_date_format.gsub! '%a', locale['abbreviated_weekday'][num_day]
      end
      if locale['full_weekday'] && locale['full_weekday'][num_day]
        translated_date_format.gsub! '%A', locale['full_weekday'][num_day]
      end
      if locale['abbreviated_month'] && locale['abbreviated_month'][num_month]
        translated_date_format.gsub! '%b', locale['abbreviated_month'][num_month]
      end
      if locale['full_month'] && locale['full_month'][num_month]
        translated_date_format.gsub! '%B', locale['full_month'][num_month]
      end

      parsed_date.strftime(translated_date_format)
    end
  end
end

Liquid::Template.register_filter(Jekyll::TranslatedDate)
