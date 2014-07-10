draw_answer_pie = (y_c, n_c, na_c, y_comments, n_comments, na_comments) ->
  elem = this[0]
  $elem = this
  data = [y_c, n_c, na_c]

  total = y_c + n_c + na_c
  w = $elem.width() - 4
  h = $elem.height() - 4
  r = Math.min(w, h) / 2
  answer_styles = [
    "fill: #ACA;" # answer_yes
    "fill: #CAA;" # answer_no
    "fill: #E5E579;" # answer_na
    "fill: #EEE;" # answer_blank
  ]
  comment_styles = [
    (if y_comments > 0 then "stroke: #666;stroke-width:1.2px;" else "")
    (if n_comments > 0 then "stroke: #666;stroke-width:1.2px;" else "")
    (if na_comments > 0 then "stroke: #666;stroke-width:1.2px;" else "")
  ]
  text_style = "font-family: \"Helvetica Neue\",Helvetica,Arial,"
  text_style += "sans-serif;" + "font-size: 10px;" + "text-anchor: middle;"
  donut = d3.layout.pie().sort(null)
  arc = d3.svg.arc().innerRadius(.4 * r).outerRadius(r - 1)

  svg = d3.select(elem)
          .append("svg:svg")
          .attr("width", w)
          .attr("height", h)
          .append("svg:g")
          .attr("transform", "translate(" + w / 2 + "," + h / 2 + ")")

  arcs = svg.selectAll("path")
            .data(donut(data))
            .enter()
            .append("svg:path")
            .attr(
              "style",(d,i)->[answer_styles[i],comment_styles[i]].join ";"
            ).attr("d", arc)

  svg.append("svg:text").attr("dy", ".4em").attr("style", text_style).text total




angular.module('case-ui.evaluation-vis',[])


.directive "evaluationPie", [ ()->

  linker = (scope, elem, attrs)->
    if scope.subQuestion()
      elem.addClass('sub_question')

    unless scope.result == undefined
      setTimeout( ()->
        draw_answer_pie.apply( elem,[
          scope.result.yes_count,
          scope.result.no_count,
          scope.result.n_a_count,
          # scope.result.blank_count,
          scope.result.yes_comment_count,
          scope.result.no_comment_count,
          scope.result.n_a_comment_count,
        ])
      ,1)

  return {
    link: linker
    scope:{
      result:"=ngModel"
      subQuestion: "&"
    }

  }

]

