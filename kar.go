// +build kar

package main

import (
	"github.com/omeid/kar"
	"github.com/omeid/kargar"

	"os/exec"

	"github.com/omeid/gonzo/context"

	"github.com/go-gonzo/css"
	"github.com/go-gonzo/fs"
	"github.com/go-gonzo/js"
	"github.com/go-gonzo/util"
)

var js_files = []string{
	"./static/assets/js/lib/jquery.mins.js",
	"./static/assets/js/lib/jquery-dropotron.min.js",
	"./static/assets/js/lib/jquery.scrollgress.min.js",
	"./static/assets/js/lib/scrolly.min.js",
}

func init() {

	kar.Run(func(build *kargar.Build) error {

		build.Meta.Name = "blog-jygastaud"
		build.Meta.Usage = "Blog build process"
		build.Meta.Version = "v0.0.1"

		//Set the build meta information.
		return build.Add(

			kargar.Task{
				Name:  "libs.js",
				Usage: "Concat frontend libraries JavaScript javascript into libs.min.js",
				Action: func(ctx context.Context) error {
					return fs.Src(ctx, js_files...).Then(
						util.Concat(ctx, "libs.js"),
						js.Minify(),
						fs.Dest("./public/assets/"),
					)
				},
			},

			kargar.Task{
				Name:  "app.js",
				Usage: "Concat frontend JavaScript into app.min.js",
				Action: func(ctx context.Context) error {
					return fs.Src(ctx, "./static/assets/js/*.js").Then(
						util.Concat(ctx, "app.js"),
						js.Minify(),
						fs.Dest("./public/assets/"),
					)
				},
			},

			kargar.Task{
				Name:  "app.css",
				Usage: "Concat frontend CSS into app.min.css",
				Action: func(ctx context.Context) error {
					return fs.Src(ctx, "./static/assets/css/*.css").Then(
						util.Concat(ctx, "app.css"),
						css.Minify(),
						fs.Dest("./public/assets/"),
					)
				},
			},

			//When running kar with no args, well, the "default" task is run.
			kargar.Task{
				Name:   "default",
				Usage:  "Start livereload, watch, and gin tasks.",
				Deps:   []string{"libs.js", "app.js", "app.css"},
				Action: kargar.Noop(),
			},
		)
	})
}
