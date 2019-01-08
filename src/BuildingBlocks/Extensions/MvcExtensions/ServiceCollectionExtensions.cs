using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ApplicationModels;
using Microsoft.AspNetCore.Mvc.Routing;

namespace MvcExtensions
{
    public static class ServiceCollectionExtensions
    {
        /// <summary>扩展 MvcOption，注册统一的路由前缀到 RouteAttribute</summary>
        public static void UseCentralRoutePrefix(this MvcOptions opts, string template)
        {
            if (string.IsNullOrEmpty(template))
                return;
            opts.Conventions.Insert(0, (IApplicationModelConvention)new GlobalRouteConvention((IRouteTemplateProvider)new RouteAttribute(template)));
        }
    }
}
