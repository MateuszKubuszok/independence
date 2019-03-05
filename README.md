# Jekyll Independence template

Jekyll template, which focuses on providing blog with rendering server side
as many things as possible, as well as tweaking it to have some SEO optimizations.

Features:

 * code rendered server-side with Rouge ([Pygments Twilight theme by Dan Simpson](https://gist.github.com/dansimpson/803005), trac for printing),
 * TeX rendered server-side with KaTeX,
 * graphs generated using Graphviz,
 * CSS is minified and compiled into 3 preloaded styles, divided by `media`,
 * self-hosted Google Fonts (Raleway, Roboto Sans) for normal text and FiraCode for code blocks,
 * JS only for Google Analytics, Disqus, and CSS preload (with JS disabled styles are loaded without preload),
 * configurable though `_config.yml`,
 * `hidded: true` front matter hides posts from links, but publishes it (compatible with pagination plugin),
 * `recommended: [/permalink1/, /permalink1/]` front matter creates reccomended posts under article,
 * `image: /images/post3.jpg` front matter replaces default H1 background with a custom one,
 * date translated with [oncleben31/jekyll-date-basic-i18n](https://github.com/oncleben31/jekyll-date-basic-i18n),
 * images which will places in `.img` class (put `{:.img}` one line before) - will be displayed without borders,
 * can be build, served and published to AWS using Docker.

Many ideas here were inspired by [Uno theme](https://github.com/joshgerdes/jekyll-uno) -
I started out by modifying Uno but at some point I decided, that writing theme
from scratch with some inspirations would be an easier way to implement my ideas.

## Blog workflow

At first, Edit `_config.yaml` to customize your site's title, URL and social media buttons.
Then update `cover.jpg` and `profile.jpg` in `images/`.
Finally, generate favicons using https://realfavicongenerator.net/ and put them
into `images/favicons/` (head is already configured):

 * select all icons in *Favicon for iOS - Web Clip*/*Assets*
 * select *create all documented icons* in *Favicon for Android Chrome*/*Assets*
 * select all icons in *Windows Metro*/*Assets*

Unfortunatelly, `favicon-96x96.png` and `favicon-194x194.png` have to be created manually
(for instance by scaling down some other favicon).

From now on, you can build and serve your blog using Docker via `make`.
It assumes that Docker daemon is already running.

If you want to publish blog on push/merge to `master`, fill out AWS secrets in `.travis.yml`.

### Local serve

Uses "debug" build which shows drafts and hides Google Analytics.

    make serve

### Publish

Uses "production" build which shows only published posts and enables Google Analytics.

    make build
    export AWS_ACCESS_KEY_ID=""
    export AWS_SECRET_ACCESS_KEY=""
    export AWS_DEFAULT_REGION=""
    export S3_BUCKET=""
    export CF_DISTRIBUTION_ID=""
    make publish

### Update dependencies

    make update

## Maintenance

In case you want to update fonts, KaTeX or Rouge files this might come handy.

### FiraCode

Download package from FiraCode GitHub releases.

Put directories with fonts into `fonts/`.

Extract `fira-code.css` into `_sass` and rename it to `fira-code.scss`.

### Font Awesome

Download ZIP from https://fontawesome.com/how-to-use/on-the-web/setup/hosting-font-awesome-yourself .

Extract `webfonts/`, `sprites/` and `svgs/` from ZIP into corresponding folders.

Extract `scss/`  into `_sass`.

Skip other files.

### Google Fonts

If you change fonts, use app like https://google-webfonts-helper.herokuapp.com/fonts to download
all files. Put fonts in `fonts/`. Edit `$standard-font` and `$special-font` in `css/common.css`.

### KaTeX

Download package from KaTeX GitHub releases.

Extract `fonts/` into `fonts/`.

Extract `katex.css` into `_sass` and rename to `katex.scss`.

## Rouge theme

If you want to change Rouge theme, you can put it into `_sass` (using `.scss` extension).
Then refer it in `css/screen.css`. You might need to edit it if you've taken it from pygments.
Pygments CSS selector is `pre.code`, while Rouge generates
`<pre class="highlight"><code>...</code></pre>` - in such case you need to adjust the theme file.
