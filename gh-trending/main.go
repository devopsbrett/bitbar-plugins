package main

import (
	"fmt"
	"net/http"
	"regexp"
	"strings"

	"github.com/PuerkitoBio/goquery"
	"github.com/spf13/pflag"
)

var timeframe string
var languages []string

const baseURL = "https://github.com"

type repo struct {
	name        string
	owner       string
	description string
	stars       string
	href        string
}

func init() {
	pflag.StringVarP(&timeframe, "timeframe", "t", "daily", "Github trending timeframe")
	pflag.StringSliceVarP(&languages, "language", "l", []string{}, "Languages to search for")
}

func main() {
	pflag.Parse()
	fmt.Println("Github")
	fmt.Println("---")
	for _, lang := range languages {
		fmt.Printf("\n---\n%s | color=blue\n---\n", strings.Title(lang))
		repos, err := getTrending(lang, timeframe)
		if err != nil {
			fmt.Printf("%s | color=red\n", err.Error())
		}
		for _, currepo := range repos {
			fmt.Println("---")
			fmt.Printf("%s / %s ⭐️ Daily: %s | size=14 href=%s\n", currepo.owner, currepo.name, currepo.stars, currepo.href)
			fmt.Println(currepo.description + " | length=70")
		}
	}
	// fmt.Println(timeframe)
	// fmt.Println(languages)
}

func getTrending(lang, tf string) ([]repo, error) {
	r := make([]repo, 0)
	url := fmt.Sprintf("%s/trending/%s?since=%s", baseURL, lang, tf)
	res, err := http.Get(url)
	if err != nil {
		return r, err
	}
	defer res.Body.Close()
	if res.StatusCode != 200 {
		return r, fmt.Errorf("Bad status code: %d %s", res.StatusCode, res.Status)
	}

	doc, err := goquery.NewDocumentFromReader(res.Body)
	if err != nil {
		return r, err
	}

	re := regexp.MustCompile(`\d+`)

	doc.Find("div.Box article.Box-row").Each(func(i int, s *goquery.Selection) {
		repostrs := strings.Split(s.Find("h1").Text(), "/")
		desc := strings.TrimSpace(s.Find("p").Text())
		stars := strings.TrimSpace(s.Find("span.float-sm-right").Text())
		singlerepo := repo{
			name:        strings.TrimSpace(repostrs[1]),
			owner:       strings.TrimSpace(repostrs[0]),
			description: desc,
			stars:       re.FindString(stars),
			href:        fmt.Sprintf("%s%s", baseURL, s.Find("h1 a").AttrOr("href", "")),
		}
		r = append(r, singlerepo)
		// fmt.Println(strings.TrimSpace(repostrs[0]))
	})
	return r, nil
}
