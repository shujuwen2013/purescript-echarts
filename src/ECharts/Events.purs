module ECharts.Events (
  EventType(..),
  EventParam(),
  Sub(),
  listen
  ) where

import Data.Function
import Control.Monad.Eff
import Data.Argonaut.Core

import ECharts.Chart
import ECharts.Effects

data EventType = Refresh | Restore | Resize | Click | DoubleClick | Hover
               | DataChanged | DataZoom | DataRange | DataRangeHoverLink
               | LegendSelected | LegendHoverLink | MapSelected | PieSelected
               | DataViewChanged | MapRoam | MagicTypeChanged

type EventParam = Json

newtype Sub = Sub (forall eff. Eff (unlisten :: Unlisten|eff) Unit)

eventStr :: EventType -> String
eventStr event = case event of 
    Refresh -> "refresh"
    Restore -> "restore"
    Resize -> "resize"
    Click -> "click"
    DoubleClick -> "dblclick"
    Hover -> "hover"
    DataChanged -> "dataChanged"
    DataZoom -> "dataZoom"
    DataRange -> "dataRange"
    DataRangeHoverLink -> "dataRangeHoverLink"
    LegendSelected -> "legendSelected"
    LegendHoverLink -> "legendHoverLink"
    MapSelected -> "mapSelected"
    PieSelected -> "pieSelected"
    DataViewChanged -> "dataViewChanged"
    MapRoam -> "mapRoam"
    MagicTypeChanged -> "magicTypeChanged"
  
                 

foreign import listenImpl """
function listenImpl(event, effHandler, chart) {
  return function() {
    var handler = function(param) {
      effHandler(param)();
    };
    chart.on(event, handler);
    return function() {
      chart.un(event, handler);
    }
  };
}
""" :: forall e.
       Fn3 String
           (EventParam -> Eff (listen::Listen|e) Unit) 
           EChart 
           (Eff (listen::Listen|e) Sub)

listen :: forall e.
          EventType ->
          (EventParam -> Eff (listen :: Listen|e) Unit) -> 
          EChart -> Eff (listen :: Listen|e) Sub
listen eventName handler chart = runFn3 listenImpl (eventStr eventName) handler chart