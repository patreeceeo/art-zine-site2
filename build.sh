#!/bin/sh -u

# TODO use GNU Make?

log() {
  # use logger?
  echo "LOG: $1" 1>&2
}

# ssource() {
#   set -x
#   set > /tmp/set1
#   . "$1"
#   set > /tmp/set2
#   the_diff=$(diff /tmp/set1 /tmp/set2)
#   echo "the_diff>>>\n$the_diff\n<<<the_diff"
#   unexpected_changes=$(echo $the_diff | perl -ne '/[<>] (.*?)=/ && print "$1\n"' | perl -ne "/($2|_)/ || print \"$_\"")
#   if [ -n "$unexpected_changes" ]; then
#     echo "the following variables were changed unexpectedly: '$unexpected_changes'"
#   fi
# }

paginate()
{
  script=$1
  shift
  prev_page=.
  page=.
  next_page=.
  for next_page in $@; do
    if [ "$page" != "." ]; then
      eval "$script"
    fi
    prev_page=$page
    page=$next_page
  done
  next_page=.
  eval "$script"
}


# responsive_image input.png $OUT_DIR $IMGWIDTH_1 $IMGWIDTH_2 $IMGWIDTH_3

# PAGES=$(ls *.html)
# set $PAGES
# for $page in $@; do
#   expand_templates "layouts/html5_boiler.html" "layouts/page_with_menu.html" $page > $OUT_DIR/$page
# done


OUT_DIR=site
ARTWORK_SIZE_SM=384
ARTWORK_SIZE_MED=768
ARTWORK_SIZE_LG=1024
ARTWORK_SIZE_XL=2048

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
export page_content=""
export artwork=""
export prev_page_href=""
export next_page_href=""
export prev_page_title=""
export next_page_title=""
export site_logo=""

echo_issue_page_source_path() {
  issue_id=$1
  page_id=$2
  echo "src/issues/$issue_id/pages/$page_id.sh"
}

echo_issue_content_path() {
  issue_id=$1
  echo "src/issues/$issue_id"
}

echo_issue_href() {
  issue_id=$1

  echo "/$OUT_DIR/issues/$issue_id"
}

echo_issue_page_href() {
  issue_id=$1
  page_name=$2
  echo "/$OUT_DIR/issues/$issue_id/$page_name.html"
}

create_issue_page() {
  issue_id="$1"
  prev_page=$(basename $2 .sh)
  page=$(basename $3 .sh)
  next_page=$(basename $4 .sh)

  prev_page_href=
  prev_page_title=
  if [ $prev_page != "." ]; then
    source_path=$(echo_issue_page_source_path $issue_id $prev_page)
    . "$source_path"
    page_name=$page_name
    prev_page_href=$(echo_issue_page_href $issue_id $page_name)
    prev_page_title=$page_title
  fi

  next_page_href=
  next_page_title=
  if [ $next_page != "." ]; then
    source_path=$(echo_issue_page_source_path $issue_id $next_page)
    . "$source_path"
    next_page_href=$(echo_issue_page_href $issue_id $page_name)
    next_page_title=$page_title
  fi

  # clear optional args
  page_content_file=

  . $(echo_issue_page_source_path $issue_id $page)

  path_prefix="issues/$issue_id/$page_img_name"
  img_ext=$page_img_ext

  if [ ! -e ".$href/$page_img_name-$ARTWORK_SIZE_SM.$img_ext" ] || [ "src/$path_prefix.$img_ext" -nt ".$href/$page_img_name-$ARTWORK_SIZE_SM.$img_ext" ]; then
    respimg "src/$path_prefix.$img_ext" ".$href/$page_img_name" \
      $ARTWORK_SIZE_XL $ARTWORK_SIZE_LG $ARTWORK_SIZE_MED $ARTWORK_SIZE_SM
  fi

  img_width=$ARTWORK_SIZE_XL
  device_min_width=$BREAKPOINT_LARGE
  sources="$(expand_template "src/partials/picture_source.html")"

  img_width=$ARTWORK_SIZE_LG
  device_min_width=$BREAKPOINT_SMALL
  sources="$sources{{}}$(expand_template "src/partials/picture_source.html")"

  img_width=$ARTWORK_SIZE_SM

  loading="lazy"
  alt="$page_img_alt"
  artwork=$(expand_template "src/partials/picture.html")

  if [ -n "${page_content_file-""}" ]; then
    page_content=$(cat "$(echo_issue_content_path $issue_id)/$page_content_file")
  fi
  page_content=$(expand_template "src/partials/issue_page.html")

  page_href=$(echo_issue_page_href $issue_id $page_name)
  url="$page_href"
  expand_template "src/layouts/site.html" > ".$(echo_issue_page_href $issue_id $page_name)"
}

create_issue() {
  id=$1
  content_path=$(echo_issue_content_path $id)
  source_path=$(echo_issue_page_source_path $id 0)
  . "$source_path"
  href=$(echo_issue_href $id)
  mkdir -p ".$href"

  pages=$(ls "$content_path/pages")
  paginate "create_issue_page \"$id\" \$prev_page \$page \$next_page" $pages
}

echo_issue_link() {
  issue_id=$1
  source_path=$(echo_issue_page_source_path $issue_id 0)
  . "$source_path"
  href=$(echo_issue_href $1)

  path_prefix="issues/$issue_id/$page_img_name"
  img_ext=$page_img_ext

  sources=
  img_width=$ARTWORK_SIZE_SM

  loading="lazy"
  alt="cover for this issue, $page_img_alt"
  cover=$(expand_template "src/partials/picture.html")

  title=$page_title
  echo $(expand_template "src/partials/article_link.html")
}

url="/"
page_title="*WHOOSH* you've arrived"
page_content=$(expand_template "src/pages/index.html")
expand_template "src/layouts/site.html" > index.html

create_issue "01-folklore"
create_issue "01.5-pickle"
create_issue "02-solarpunk"

issue_links=$(echo_issue_link "02-solarpunk")
issue_links="$issue_links{{}}$(echo_issue_link "01.5-pickle")"
issue_links="$issue_links{{}}$(echo_issue_link "01-folklore")"

path_prefix="images/logo"
img_ext="png"

img_width=85
device_min_width=$BREAKPOINT_LARGE
sources="$(expand_template "src/partials/picture_source.html")"

img_width=34

loading="lazy"
alt="the concrete gorilla itself"
site_logo=$(expand_template "src/partials/picture.html")

url="/site"
page_title="*WHOMP* glad you could make it"
page_content=$(expand_template "src/pages/home.html")
expand_template "src/layouts/site.html" > $OUT_DIR/index.html


mkdir -p site/css
cp src/css/* site/css/

mkdir -p site/images
make

