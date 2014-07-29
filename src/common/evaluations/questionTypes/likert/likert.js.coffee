angular.module("case-ui.evaluations.question-types.likert", [])


.factory "likertQuestionType", ()->
  {
    response_options:
      "1": "Strongly Disagree"
      "2": "Disagree"
      "3": "Neither agree nor disagree"
      "4": "Agree"
      "5": "Strongly Agree"
    render: ($elem, resp)->
      data = [
        resp.strongly_agree_count || 0,
        resp.agree_count || 0,
        resp.neither_aggree_nor_disagree_count || 0,
        resp.disagree_count || 0,
        resp.strongly_disagree_count || 0]

      elem = $elem[0]
      $elem.empty()

      total = 0
      for count in data
        total += count

      w = $elem.width() - 4
      h = $elem.height() - 4
      r = Math.min(w, h) / 2
      answer_styles = [
        "fill: #ACA;" # answer_yes
        "fill: #CAA;" # answer_no
        "fill: #E5E579;" # answer_na
        "fill: #8F0;" # answer_blank
        "fill: #6BE;" # answer_blank
      ]
      # comment_styles = [
      #   (if y_comments > 0 then "stroke: #666;stroke-width:1.2px;" else "")
      #   (if n_comments > 0 then "stroke: #666;stroke-width:1.2px;" else "")
      #   (if na_comments > 0 then "stroke: #666;stroke-width:1.2px;" else "")
      # ]
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
                  "style",(d,i)->[answer_styles[i]].join ";"
                ).attr("d", arc)

      svg.append("svg:text")
         .attr("dy", ".4em")
         .attr("style", text_style)
         .text total




  }