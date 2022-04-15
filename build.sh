#!/bin/sh -u

log() {
  echo "LOG: $1" 1>&2
}

paginate()
{
  script=$1
  shift
  prev_page=
  page=
  for next_page in $@; do
    if [ -n "$page" ]; then
      eval "$script"
    fi
    prev_page=$page
    page=$next_page
  done
  next_page=
  eval "$script"
}


# responsive_image input.png $OUT_DIR $IMGWIDTH_1 $IMGWIDTH_2 $IMGWIDTH_3

# PAGES=$(ls *.html)
# set $PAGES
# for $page in $@; do
#   expand_templates "layouts/html5_boiler.html" "layouts/page_with_menu.html" $page > $OUT_DIR/$page
# done

# COVER_IMAGE_SIZES="555 352 152"

OUT_DIR=site
COVER_IMAGE_SIZE_SM=152
COVER_IMAGE_SIZE_MED=352
COVER_IMAGE_SIZE_LG=566

BREAKPOINT_LARGE=1024
BREAKPOINT_SMALL=768

export issue_links=""
export cover=""
export sources=""
export path_prefix=""
export img_ext=""
export img_width=""
export device_min_width=""
export loading=""
export alt=""
export href=""
export title=""
export excerpt=""
export page_title=""
export url=""
export page_image=""
export site_nav=""
export site_footer=""
export page_content=""

create_issue() {
  path=$1
  title=$2
  href="$OUT_DIR/issues/$path"
  mkdir -p $href

  path_prefix="issues/$path/cover"
  img_ext=$3
  respimg "src/$path_prefix.$img_ext" "$href/cover" \
    $COVER_IMAGE_SIZE_LG $COVER_IMAGE_SIZE_MED $COVER_IMAGE_SIZE_SM

  img_width=$COVER_IMAGE_SIZE_SM
  device_min_width=$BREAKPOINT_LARGE
  sources="$(expand_template "src/partials/picture_source.html")"

  img_width=$COVER_IMAGE_SIZE_MED
  device_min_width=$BREAKPOINT_SMALL
  sources="$sources{{}}$(expand_template "src/partials/picture_source.html")"

  img_width=$COVER_IMAGE_SIZE_LG

  loading="lazy"
  alt="cover for this issue, $4"
  cover=$(expand_template "src/partials/picture.html")

  link=$(expand_template "src/partials/article_link.html")
  if [ -n "$issue_links" ]; then
    issue_links="$issue_links{{}}$link"
  else
    issue_links=$link
  fi
}

rm -rf $OUT_DIR
mkdir $OUT_DIR

url="/"
page_title="*WHOOSH* you've arrived"
page_content=$(expand_template "src/pages/index.html")
expand_template "src/layouts/site.html" > index.html

create_issue "01-folklore" "issue #1: folklore" png "a fairy carrying a fountain pen."
create_issue "01.5-pickle" "issue #1.5: pickle" jpg "a very cute pickle"

url="/site"
page_title="*WHOOSH* you've arrived"
page_title="*WHOMP* glad you could make it"
page_content=$(expand_template "src/pages/home.html")
expand_template "src/layouts/site.html" > $OUT_DIR/index.html

